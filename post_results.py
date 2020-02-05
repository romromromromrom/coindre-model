import hydrolix_client as hx
import datetime as dt
import pandas as pd
import pytz

def post_results2hdx(common_dir):

    print(r'... POSTING RESULTS ... POSTING RESULTS ... POSTING RESULTS ... ')
    c = hx.Client(api_key = '5bpodg6vmy18lqtq949u4psgh0mb5lfxg0bz326jmpxnma3w8r7tntb9y4j1hzlj')
    BRU = pytz.timezone('Europe/Brussels')
    version = BRU.localize(dt.datetime.now().replace(minute=0, second=0, microsecond=0))
    scenario ='coindre_model'


    df = pd.read_excel(common_dir + r'\run_results.xlsx' ,index_col=0, sheet_name='results')
    drange = pd.to_datetime(df.index).tz_convert('Europe/Brussels')
    df2 = pd.DataFrame(data= df.values, index= drange, columns=df.keys())
    power_schedule = df2.loc[:,['p(t)']].rename(columns={'p(t)':'Value'})

    vane_schedule = (1 - df2.loc[:,['Vane CLOSED']]/10).rename(columns={'Vane CLOSED':'Value'})

    c.post_parameter_timeseries_data(power_schedule,'Coindre_T' ,'production' , scenario, version)
    c.post_parameter_timeseries_data(vane_schedule,'Petite-Rhue_R', 'valve_position', scenario, version)

if __name__=='__main__':
    common_dir = os.path.dirname(os.path.realpath(__file__))
    post_results2hdx(common_dir)