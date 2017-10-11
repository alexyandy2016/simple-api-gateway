
import Vue from 'vue';
import axios from 'axios';
import requests from './requests.vue';

function component() {
    var element = document.createElement('div');
    element.id = 'app';
    return element
}

document.body.appendChild(component());

new Vue({
    el: '#app',
    render: h => h(requests)
});


