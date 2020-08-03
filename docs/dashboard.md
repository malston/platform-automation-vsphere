# Grafana Dashboards

All Grafana dashboards are maintained in version control in the [./dashboards](./dashboards) folder under the root directory. After installing a new foundation with [Healthwatch](https://docs.pivotal.io/platform/healthwatch/2-0/index.html), you can import your own dashboards or you can export the latest dashboards that come installed with [Healthwatch](https://docs.pivotal.io/platform/healthwatch/2-0/index.html).

## Importing Dashboards

- To import a set of dashboards located under a folder

    ```sh
    ./scripts/import-dashboards.sh --path=gap
    ```

    This command requires a `folder.json` in the `gap` folder to indicate where the dashboard goes in Grafana

- To import a set of dashboards located under a folder named 'Enterprise PKS'

    ```sh
    ./scripts/import-dashboards.sh --path=gap --folder='Enterprise PKS'
    ```

    This command does not require there to be a `folder.json` file under the `gap` path.

- To import all the dashboards, you need to make sure you have a `folder.json` in every folder.

    ```sh
    ./scripts/import-dashboards.sh --all
    ```

    This will recurse through all the directories under the [./dashboards](./dashboards) folder and for each directory containing a `folder.json` file, it will import the dashboards into a Grafana folder named by the title `'{ "title": "Foundation" }'` in `folder.json`.

## Exporting Dashboards

- To export a set of dashboards located under a folder

    ```sh
    ./scripts/export-dashboards.sh --path=hw2/pks/1.7
    ```

    This will first look for a `folder.json` file. If there isn't one, then it will fail gracefully.

- If you don't have a `folder.json` file, then you can specify the folder name instead

    ```sh
    ./scripts/export-dashboards.sh --path=hw2/pks/1.7 --folder='Enterprise PKS'
    ```

- To export all the dashboards, you need to make sure you have a `folder.json` in every folder.

    ```sh
    ./scripts/export-dashboards.sh --all
    ```

    This will update the `folder.json` with all the metadata it gets from looking up the folder and updates all the dashboards.
