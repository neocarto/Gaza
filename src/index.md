---
theme: [ocean-floor]
---


<details>
  <summary>Click me</summary>

Since October 7, 2023, bombardments have rained down on Gaza. An entire people is being massacred. An entire country has been brought to its knees. Schools, hospitals, universities - everything is being methodically destroyed under the orders of Benjamin Netanyahu's far-right government, which continues its criminal headlong rush.

But how to account for the scale of such a massacre? One possible method is to analyze satellite images. And this is precisely the method employed by UNOSAT, the United Nations Satellite Center. To do this, UNOSAT mobilized 8 sets of satellite images spanning the period from October 15, 2023 to July 6, 2024 to meticulously identify, date by date, the damage caused by the Israeli army's bombardment and incursion. The results are overwhelming: 46,223 structures destroyed, 18,478 severely damaged, 55,954 moderately damaged and 35,754 probably damaged. In all, some 156,409 structures were destroyed, representing around 63% of all structures in the Gaza Strip. After the war, everything will have to be rebuilt.

The balance sheet is therefore edifying. The popular response must be equal to the drama unfolding in Gaza. Unwavering solidarity with our Palestinian brothers and sisters fighting for their freedom. General mobilization for a just and lasting peace between Palestinians and Israelis.
</details>

```js
display(html`<link rel="stylesheet" href="${import.meta.resolve("npm:maplibre-gl/dist/maplibre-gl.css")}">`);
import maplibregl from "npm:maplibre-gl";
```

# Bombs rain down on Gaza

```js
let select = view(Inputs.select(
  new Map(dates.map((d) => [d.label, d.class]).reverse()),
  {
    value: "",
    label: "Damage and destruction at"
  }
))
```


```js
let text = html`Au <b>${day.get(
  select
)}</b>, Based on satellite images, the United Nations Satellite Center (UNOSAT) had counted <b>${dispdata.length.toLocaleString(
  "fr-FR"
)} </b>damage and destruction of structures in the Gaza Strip (source: <a href="https://unosat.org/products/3904">unosat.org/products/3904</a>).`
display(text)
```

```js
let gaza = html`<div  class="card" style="height:600px"></div>`
display(gaza)
```




```js
  let hovereId = null;
  //const container = yield html`<div style="height:500px;">`;

  const map = new maplibregl.Map({
    container: gaza,
    zoom: 10.5,
    bearing: -50,
    //bounds: bb,
    center: [34.4017, 31.4067],
    //pitch: 52,
    //hash: true,
    style: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
    attributionControl: false
    //maxZoom: 18,
    //maxPitch: 85
  });

  map.on("load", function () {
    // Data source
    map.addSource("unosat", {
      type: "geojson",
      data: geodata
    });

    // Add heatmap
    map.addLayer(
      {
        id: "heatlayer",
        type: "heatmap",
        source: "unosat",
        maxzoom: 17,
        paint: {
          // Increase the heatmap weight based on frequency and property magnitude
          // "heatmap-weight": [
          //   "interpolate",
          //   ["linear"],
          //   ["get"],
          //   //["get", "Main_Damage_Site_Class_8"],
          //   0,
          //   0,
          //   6,
          //   1
          // ],
          //"heatmap-intensity": 10,
          "heatmap-intensity": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10.5,
            0.2,
            15,
            10
          ],
          "heatmap-color": [
            "interpolate",
            ["linear"],
            ["heatmap-density"],
            0,
            "rgba(33,102,172,0)",
            0.2,
            "rgb(103,169,207)",
            0.4,
            "rgb(209,229,240)",
            0.6,
            "rgb(253,219,199)",
            0.8,
            "rgb(239,138,98)",
            1,
            "rgb(178,24,43)"
          ],
          "heatmap-radius": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10.5,
            6,
            15,
            8
          ],
          "heatmap-opacity": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10.5,
            1,
            15,
            1,
            17,
            0.3
          ]
        }
      },
      "waterway"
    );

    // Add layer dots
    map.addLayer({
      id: "dots",
      type: "circle",
      source: "unosat",
      minzoom: 13,
      paint: {
        "circle-color": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          "red",
          "black"
        ],

        "circle-opacity": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          0.5,
          15.5,
          1
        ],
        "circle-radius": ["interpolate", ["linear"], ["zoom"], 13, 1, 20, 10]
      }
    });

    // Popup
    const popup = new maplibregl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    map.on("mousemove", "dots", function (e) {
      map.getCanvas().style.cursor = "pointer";
      const coordinates = e.features[0].geometry.coordinates.slice();
      const description = `Ville : ${e.features[0].properties.Municipality}<br/>
${siteclass.get(e.features[0].properties.Main_Damage_Site_Class_8)}`;
      popup.setLngLat(coordinates).setHTML(description).addTo(map);
      if (e.features.length > 0) {
        if (hovereId) {
          map.setFeatureState(
            { source: "unosat", id: hovereId },
            { hover: false }
          );
        }
        hovereId = e.features[0].properties.id;
        map.setFeatureState(
          { source: "unosat", id: hovereId },
          { hover: true }
        );
      }
    });
    map.on("mouseleave", "dots", function () {
      map.getCanvas().style.cursor = "";
      popup.remove();
      if (hovereId) {
        map.setFeatureState(
          { source: "unosat", id: hovereId },
          { hover: false }
        );
      }
      hovereId = null;
    });
  });

  map.addControl(new maplibregl.NavigationControl(), "top-right");
  map.addControl(new maplibregl.FullscreenControl());
  map.addControl(
    new maplibregl.AttributionControl({
      customAttribution: `Nicolas Lambert, 2024 - UNOSAT Gaza Strip 8th Comprehensive Damage Assessment - July 2024 (https://unosat.org/products/3904)`,
      compact: true
    })
  );
  invalidation.then(() => map.remove());

```

```js
// DATA IMPORT AND HANDLING
let data = await FileAttachment("data/data.csv")
  .csv()
  let features = data.map((d) => ({
    type: "Feature",
    properties: d,
    geometry: { type: "Point", coordinates: [d.X, d.Y] }
  }));
  let geodata =  { type: "FeatureCollection", features };

```

```js
  if (map.isStyleLoaded()) {
    map.setFilter("heatlayer", [
      "all",
      ["!=", ["get", select], "NA"],
      ["!=", ["get", select], 6]
    ]);
    map.setFilter("dots", [
      "all",
      ["!=", ["get", select], "NA"],
      ["!=", ["get", select], 6]
    ]);
  } else {
    null;
  }

```

```js
let dispdata = data
  .filter((d) => d[select] != "NA")
  .filter((d) => d.Main_Damage_Site_Class_8 != 6)
```

```js
// DATES
let options = ({ weekday: "long", year: "numeric", month: "long", day: "numeric" })
let dates = [
  {
    date: data[0].SensorDate,
    label: new Date(data[0].SensorDate).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class",
    status: "Damage_Status"
  },
  {
    date: data[0].SensorDate_2,
    label: new Date(data[0].SensorDate_2).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_2",
    status: "Damage_Status_2"
  },
  {
    date: data[0].SensorDate_3,
    label: new Date(data[0].SensorDate_3).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_3",
    status: "Damage_Status_3"
  },
  {
    date: data[0].SensorDate_4,
    label: new Date(data[0].SensorDate_4).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_4",
    status: "Damage_Status_4"
  },
  {
    date: data[0].SensorDate_5,
    label: new Date(data[0].SensorDate_5).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_5",
    status: "Damage_Status_5"
  },
  {
    date: data[0].SensorDate_6,
    label: new Date(data[0].SensorDate_6).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_6",
    status: "Damage_Status_6"
  },
  {
    date: data[0].SensorDate_7,
    label: new Date(data[0].SensorDate_7).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_7",
    status: "Damage_Status_7"
  },
  {
    date: data[0].SensorDate_8,
    label: new Date(data[0].SensorDate_8).toLocaleDateString("en-EN", options),
    class: "Main_Damage_Site_Class_8",
    status: "Damage_Status_8"
  }
]
let day = new Map(dates.map((d) => [d.class, d.label]))
```

```js
// TABLES
let siteclass = new Map([
  [1, "Destroyed"],
  [2, "Severe Damage"],
  [3, "Moderate Damage"],
  [4, "Possible Damage"],
  [5, "Impact Crater (Damage to Road)"],
  [6, "No Visible Damage"],
  [7, "Impact Crater (Damage to Field)"],
  [8, "Destroyed (Demolition Zone)"],
  [9, "Suspected Phosphorus shell Attack Zone"],
  [10, "Road Damage from Tank Passage"],
  [11, "Possible Damage from adjacent impact, debris"],
  [12, "Lava Flow"],
  [13, "Damage"]
])
let total = 215137
```

```js
// IMAGES
let loading = await FileAttachment("loading.gif").url()
let check = await FileAttachment("check@1.png").url()

```

