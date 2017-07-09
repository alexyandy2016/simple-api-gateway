
import Vue from 'vue';
import VueRouter from 'vue-router';
import axios from 'axios';
import App from './App.vue';

function component() {
    var element = document.createElement('div');
    element.id = 'app';
    return element
}

document.body.appendChild(component());

new Vue({
    el: '#app',
    render: h => h(App)
});


