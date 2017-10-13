import Vue from 'vue';
import axios from 'axios';
import requests from './requests.vue';

axios.defaults.baseURL = 'http://127.0.0.1:8000';
axios.defaults.headers.get['Content-Type'] = 'application/json';

function component() {
    var element = document.createElement('div');
    element.id = 'app';
    return element
}

document.body.appendChild(component());
Vue.prototype.axios = axios;
new Vue({
    el: '#app',
    axios,
    render: h => h(requests)
});


