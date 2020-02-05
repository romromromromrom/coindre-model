import logging
import datetime
import requests
import urllib3
import pytz
from requests_ntlm import HttpNtlmAuth

DEFAULT_TZ = pytz.timezone('Europe/Brussels')

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

logger = logging.getLogger(__name__)

# Note the swagger.son is available here if we want to use something like Bravado:
# https://xs006475.win.corp.com/piwebapi/help/specification?pretty=true

#PI_DEFAULT_URL = 'https://xs006475.win.corp.com/piwebapi'
#PI_DEFAULT_AF_PATH_ROOT = r'\\XS006475 - INT\Dev-Egenco\SHEM'
PI_DEFAULT_URL = 'https://webatlas.myengie.com/piwebapi'
PI_DEFAULT_AF_PATH_ROOT = r'\\piatlas.myengie.com'
BYPASS_PROXY = True


class RequestError(Exception):
    pass


class Client(object):
    def __init__(self, api_base_url=None, af_path_root=None, bypass_proxy=None):
        self.url = api_base_url or PI_DEFAULT_URL
        self.af_root = af_path_root or PI_DEFAULT_AF_PATH_ROOT

        session = requests.Session()
        session.auth = HttpNtlmAuth('CORP\\CDN560', '4KHMgqxnVjSD')

        if bypass_proxy or BYPASS_PROXY or False:
            self.proxies = {'http': None, 'https': None}
            session.proxies.update(self.proxies)
        else:
            self.proxies = None

        self.s = session

    def call_pi_uri(self, uri, parse_json=False, **kwargs):
        logger.info('calling Pi with uri {}'.format(uri))
        url = self._url(uri)
        response = self.s.request('get', url, verify=False, proxies=self.proxies, **kwargs)

        if response.status_code not in (200, 204):
            raise RequestError('Pi request failed with code {} ({} - {})'.format(
                response.status_code, response.reason, response.text))

        if parse_json:
            return response.json()
        return response.text

    def get_pi_summary_data(self, start_date, end_date, webid=None, tag=None, step=None, type=None):
        if tag is not None and webid is None:
            webid = self.get_webid_for_tag(tag)

        params = dict()
        params['startTime'] = self._to_iso(start_date)
        params['endTime'] = self._to_iso(end_date)

        if step is not None:
            params['summaryDuration'] = step
        if type is not None:
            params['summaryType'] = type

        return self.call_pi_uri('streams/{}/summary'.format(webid), True, params=params)

    def get_interpolated_data(self, start_date, end_date, webid=None, tag=None, step=None):
        if tag is not None and webid is None:
            webid = self.get_webid_for_tag(tag)

        params = dict()
        params['startTime'] = self._to_iso(start_date)
        params['endTime'] = self._to_iso(end_date)
        if step is not None:
            params['interval'] = step

        return self.call_pi_uri('streams/{}/interpolated'.format(webid), True, params=params)

    def get_webid_for_tag(self, tag):
        params = {'path': self.get_af_path(tag)}

        resp_dict = self.call_pi_uri('attributes', True, params=params)
        return resp_dict['WebId']

    def get_af_path(self, tag):
        return '\\'.join((self.af_root, tag))

    def _url(self, part):
        return '/'.join((self.url, part.lstrip('/')))

    def _to_iso(self, date):
        if isinstance(date, str):
            return date
        if isinstance(date, datetime.datetime) and date.tzinfo is None:
            date = DEFAULT_TZ.localize(date)

        return date.isoformat()


def summary_resp_to_df(resp_dict):
    import pandas as pd

    values = [v['Value'] for v in resp_dict['Items']]
    df = pd.DataFrame.from_records(values,
                                   columns=['Timestamp', 'Value',
                                            'UnitsAbbreviation', 'Good',
                                            'Questionable', 'Substituted'])

    df['Timestamp'] = pd.to_datetime(df['Timestamp'], utc=True)

    df['Value'] = pd.to_numeric(df['Value'], errors='coerce')
    return df

def _interpolated_resp_to_df(resp_dict):
    import pandas as pd
    values = resp_dict['Items']
    df = pd.DataFrame.from_records(values, columns=['Timestamp', 'Value'])
    # 'UnitsAbbreviation', 'Good', 'Questionable', 'Substituted'
    df['Timestamp'] = pd.to_datetime(df['Timestamp'], utc=True)
    df['Value'] = pd.to_numeric(df['Value'], errors='coerce')
    return df