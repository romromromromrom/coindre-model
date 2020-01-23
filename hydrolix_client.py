import os
import sys
import json
from collections import OrderedDict
import requests
import datetime
import pandas as pd
import pytz

DEFAULT_TZ = pytz.timezone('Europe/Brussels')
UTC = pytz.UTC


class RequestError(Exception):
    pass


class Client:
    def __init__(self,
                 base_url='https://hydro.bluesafire.io/api',
                 api_key='your api key goes here'):
        self.url = base_url

        session = requests.Session()
        session.auth = requests.auth.HTTPBasicAuth(api_key, '')
        #session.verify = False

        self.s = session

    def _url(self, part):
        return '/'.join((self.url, part.lstrip('/')))

    def _get(self, url, format='response', accepted=(200, ), *args, **kwargs):

        response = self.s.get(url, *args, **kwargs)

        if accepted and response.status_code not in accepted:
            raise RequestError('GET {} failed with code {} ({})'.format(
                url, response.status_code, response.text))

        if format == 'list':
            data = json.loads(response.content, object_pairs_hook=OrderedDict)
            return data

        return response

    def _post(self, url, data=None, json=None, accepted=(200, ), *args, **kwargs):
        response = self.s.post(url, data, json, *args, **kwargs)

        if accepted and response.status_code not in accepted:
            raise RequestError('POST {} failed with code {} ({})'.format(
                url, response.status_code, response.text))

        return response

    def _to_iso(self, date):
        if isinstance(date, str):
            return date
        date = self._to_utc_dt(date)

        return date.isoformat()

    def _to_utc_dt(self, date):
        if date is None:
            return None

        if isinstance(date, pd.Timestamp):
            date = date.to_pydatetime()
        elif isinstance(date, datetime.datetime):
            # because a datetime.datetime seems to ne also a datetime.date
            pass
        elif isinstance(date, datetime.date):
            date = datetime.datetime.combine(date, datetime.time.min)

        if isinstance(date, datetime.datetime):
            if date.tzinfo is None:
                date = DEFAULT_TZ.localize(date)

        date = date.astimezone(UTC)

        return date

    def _parse_dt_cols(self, df, column_names):
        for col in column_names:
            df[col] = pd.to_datetime(df[col], utc=True).dt.tz_convert(DEFAULT_TZ)

    def get_production_plan(self, system, start_date, end_date,
                            until_version=None, format='df'):
        kwargs = dict()
        kwargs['start'] = self._to_iso(start_date)
        kwargs['end'] = self._to_iso(end_date)
        if until_version is not None:
            kwargs['until_version'] = self._to_iso(until_version)

        resp = self._get(self._url('production_plan/gem/{}'.format(system)),
                         format='list',
                         params=kwargs)

        if format == 'df':
            df = pd.DataFrame(resp['production'])
            self._parse_dt_cols(df, ['index'])
            df.set_index('index', inplace=True)
            return df

        return resp

    def get_da_production_plan(self, system, start_date, end_date, cutoff_hour=16,
                               cutoff_min=30):
        plans = []

        start_date = start_date.replace(tzinfo=None)
        end_date = end_date.replace(tzinfo=None)

        date = start_date
        while date < end_date:
            until = date - datetime.timedelta(days=1) \
                    + datetime.timedelta(hours=cutoff_hour, minutes=cutoff_min)

            plans.append(self.get_production_plan(system, date,
                                             date + datetime.timedelta(days=1),
                                             until))
            date = date + datetime.timedelta(days=1)

        if len(plans) > 0:
            df = pd.concat(plans, axis=0)
        else:
            df = pd.DataFrame()

        return df

    def get_node_calculated_timeseries(self, target_name, param, start_date, end_date,
                                      scenario, frequency='1h', format='df'):
        kwargs = dict()
        kwargs['start'] = self._to_iso(start_date)
        kwargs['end'] = self._to_iso(end_date)
        kwargs['scenario'] = scenario
        kwargs['frequency'] = frequency

        resp = self._get(self._url(f'node/{target_name}/calculated_timeseries/{param}'),
                         format='list',
                         params=kwargs)

        if format == 'df':
            df = pd.DataFrame(resp)
            self._parse_dt_cols(df, ['index'])
            df.set_index('index', inplace=True)
            return df

        return resp

    def post_parameter_timeseries_data(self, df, target, parameter, scenario, version):
        if len(df.columns) > 1:
            raise RequestError('input dataframe should only have one column')

        if not df.index.is_all_dates:
            raise RequestError('input dataframe should have datetimes for index')

        df = df.dropna()

        payload = {
            'data': {
                'index': [d.isoformat() for d in df.index],
                'value': df[df.columns[0]].astype(float).tolist()
            },
            'scenario_name':  scenario,
            'version': self._to_iso(version)
        }

        url = self._url(f'/node/{target}/timeseries/{parameter}')
        self._post(url, json=payload)

    def get_parameter_timeseries_data(self, target, parameter, scenario,
                                      from_version=None, until_version=None,
                                      start_date=None, end_date=None,
                                      format='df'):
        kwargs = dict()
        kwargs['scenario_name'] = scenario
        kwargs['start'] = self._to_iso(start_date or datetime.datetime(1900, 1, 1))
        kwargs['end'] = self._to_iso(end_date or datetime.datetime(2199, 1, 1))

        if from_version is not None:
            kwargs['from_version'] = self._to_iso(from_version)
        if until_version is not None:
            kwargs['until_version'] = self._to_iso(until_version)

        resp = self._get(self._url(f'node/{target}/timeseries/{parameter}'),
                         format='list',
                         params=kwargs)

        if format == 'df':
            df = pd.DataFrame(resp)
            self._parse_dt_cols(df, ['index'])
            df.set_index('index', inplace=True)
            return df

        return resp

    def get_run_results(self, run_id, parameter, start_date=None, end_date=None, pagode_scenarios=None, format='df'):
        kwargs = dict()
        kwargs['pagode_scenarios'] = pagode_scenarios

        if format != 'df' and (start_date is not None or end_date is not None):
            raise RequestError('start_date and end_date can only by used with format="df"')

        resp = self._get(self._url(f'runexecution/{run_id}/results/{parameter}'),
                         format='list',
                         params=kwargs)

        if format == 'df':
            df = pd.DataFrame(resp['data'])
            df = df.reindex(columns=resp['order'])

            index_col = None
            if 'Date' in df.columns:
                index_col = 'Date'
            elif 'index' in df.columns:
                index_col = 'index'

            if index_col is not None:
                try:
                    self._parse_dt_cols(df, [index_col])
                    df.set_index(index_col, inplace=True)
                except:
                    pass

            if start_date is not None or end_date is not None:
                df = df[self._to_utc_dt(start_date):self._to_utc_dt(end_date)]

            return df

        return resp

    def upload_meteor_prices(self, file_path):
        url = self._url('meteor_prices/upload')
        filename = os.path.basename(file_path)
        multipart_form_data = {
            'file': (filename, open(file_path, 'rb')),
        }

        resp = self.s.post(url, data=None, files=multipart_form_data)
        return resp.json()

    def get_task_status(self, task_id):
        resp = self._get(self._url(f'task/{task_id}/status'))
        return resp.json()

    def download_media_file(self, filename, target_folder=None):
        url = self._url('download_file/' + filename)
        r = self.s.get(url)

        if r.status_code != 200:
            raise RequestError('GET {} failed with code {} ({})'.format(
                url, r.status_code, r.text))

        if target_folder is None:
            return r.content

        # only keep abc.txt in subfolder/subfolder/abc.txt
        filename = filename.split('/')[-1]

        with open(os.path.join(target_folder, filename), "wb") as f:
            f.write(r.content)



class ChuncksOfFile:
    def __init__(self, filename, chunk_size=1 << 13):
        self.filename = filename
        self.chunk_size = chunk_size
        self.total_size = os.path.getsize(filename)
        self.read_so_far = 0

    def __iter__(self):
        with open(self.filename, 'rb') as file:
            while True:
                data = file.read(self.chunk_size)
                if not data:
                    sys.stderr.write('\n')
                    break
                self.read_so_far += len(data)
                percent = self.read_so_far * 1e2 / self.total_size
                sys.stderr.write('\r{percent:3.0f}%'.format(percent=percent))
                yield data

    def __len__(self):
        return self.total_size

