// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("chartkick")
require("chart.js")
require("jquery")
require ("popper.js")
import "bootstrap"
import Chart from 'chart.js'
import ChartDataLabels from 'chartjs-plugin-datalabels'

// Change default options for ALL charts
Chart.defaults.global.layout =  {

    padding: {
        left: 10,
            right: 10,
            top: 30,
            bottom: 30
    }
}

// Change default options for datalabel for ALL charts
Chart.helpers.merge(Chart.defaults.global.plugins.datalabels, {
    color: '#555',
    anchor: 'end',
    align : 'end',
    offset: '4',
});





// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
