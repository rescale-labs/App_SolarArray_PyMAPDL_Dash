# Solar Array Designer

Solar Array Designer is a [Dash](https://dash.plotly.com/) web app created by Steve Kiefer for his [ANSYS in a Python Web App application article](https://towardsdatascience.com/ansys-in-a-python-web-app-part-2-pre-processing-solving-with-pymapdl-50428c18f8e7). We have cloned the [original repository](https://github.com/shkiefer/pyAnsys_MAPDL_dash) and made a few changes to make it a Rescale App. The goal is to demonstrate how to port an existing Dash web app to Rescale.

We encourage you to read Steve's original article, which includes an in-depth walkthrough the application code.

For introduction to Rescale Apps, see [Hello World Rescale App](https://github.com/rescale-labs/App_HelloWorld_Flask).

## Quick start

Currently, Rescale Apps rely on the `jupyter4all` flag which needs to be enabled for the user, workspace or company. See Hello World repository for details.

### Deploying a Rescale App as Job inputs

Packaging a Dash web app for deployment is straightforward. While inside the root directory of the cloned code repository, issue a zip command to create a web app archive. Create a new Job, upload the archive as inputs, select *ANSYS Mechanical* software tile, set `. launch.sh` as a command, select hardware with 2+ cores and submit.

```
❯ git clone https://github.com/rescale-labs/App_SolarArray_PyMAPDL_Dash
❯ cd App_SolarArray_PyMAPDL_Dash
❯ zip -r webapp.zip *
```

The review page of your Job should look like this.

![](README.images/dash_job_setup.png)

Once started, look at the Job Logs section and search for the line mentioning the Notebook server. Highlight the link and open it in a new tab.

![](README.images/webapp_url.png)

In the new tab with the Rescale App, click `Solve` to start calculation. Once finished, interact with the visualization to zoom, rotate, pan results overlaid on solar array geometry.

![](README.images/dash_rescale_app.png)

### Publishing a Rescale App using Rescale Software Publisher

A Rescale App can be published as a separate software tile. The resulting user experience is presented below.

> TODO: Stay tuned for instructions...

![](README.images/solar_array_designer.gif)

## Dash web app porting notes

The most important change is to set the new, prefixed, root route for the application. By default, it is set to `/`, so we need to let Dash Single Page Application (SPA) know from where to serve static content. We also need to let the frontend, running in a browser, to send appropriately prefixed requests back to the server side of a Dash application. This is done by passing `routes_pathname_prefix` and `requests_pathname_prefix` parameters to the `Dash()` app constructor.

The current `jupyter4all` hack requires prefixing with `/notebooks/` followed by a cluster ID that is extracted from the `RESCALE_CLUSTER_ID` environmental variable.

```
PREFIX = f"/notebooks/{os.getenv('RESCALE_CLUSTER_ID')}/"

app = dash.Dash(
    __name__,
    long_callback_manager=lcm,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    routes_pathname_prefix=PREFIX,
    requests_pathname_prefix=PREFIX,
)
```

Additionally, future Rescale App integration with the ScaleX platform will require a discovery endpoint, which provides metadata about the app. This endpoint is expected to have the following address `${PREFIX}/.rescale-app`. Content returned from getting this resource is a JSON Rescale App metadata document.

An example of how to add this endpoint to a Dash web app is presented below.

```
class RescaleAppDiscovery(Resource):
    def get(self):
        return {
            "name": "Solar Array Designer",
            "description": "An example of a Rescale App using ANSYS PyMAPDL module and the Dash web framework",
            "helpUrl": "https://github.com/rescale-labs/App_SolarArray_PyMAPDL_Dash",
            "icon": app.get_asset_url("app_icon.png"),
            "supportEmail": "support@rescale.com",
            "webappUrl": PREFIX,
            "isActive": True,
        }

server = app.server
api = Api(server)
api.add_resource(RescaleAppDiscovery, f"{PREFIX}/.rescale-app")
```

The [launch.sh](launch.sh) script applies the `jupyter4all` hack and starts the web app in a context of a gunicorn web server, which uses platform provided certificate and key files to ensure a secure HTTP connection between the app and the ScaleX platform.