<template>
    <div id="app">
        <img src="./assets/logo.png">
        <h1></h1>
        <h2>Essential Links</h2>
        <ul>
            <li><a href="https://vuejs.org" target="_blank">Core Docs</a></li>
            <li><a href="https://forum.vuejs.org" target="_blank">Forum</a></li>
            <li><a href="https://gitter.im/vuejs/vue" target="_blank">Gitter Chat</a></li>
            <li><a href="https://twitter.com/vuejs" target="_blank">Twitter</a></li>
        </ul>
        <h2>Ecosystem</h2>
        <ul>
            <li><a href="http://router.vuejs.org/" target="_blank">vue-router</a></li>
            <li><a href="http://vuex.vuejs.org/" target="_blank">vuex</a></li>
            <li><a href="http://vue-loader.vuejs.org/" target="_blank">vue-loader</a></li>
            <li><a href="https://github.com/vuejs/awesome-vue" target="_blank">awesome-vue</a></li>
        </ul>
    </div>
</template>

<script>
    export default {
        name: 'app',
        data () {
            return {
                msg: 'Welcome to Your Vue.js App'
            }
        }
    }
</script>

<style type="text/css">
    div {
        display: block;
    }

    h5 {
        font-size: 14px;
    }

    h1, h2, h3, h4, h5, h6 {
        margin: 10px 0;
        font-family: inherit;
        font-weight: bold;
        line-height: 20px;
        color: inherit;
        text-rendering: optimizelegibility;
    }

    .request-detail .key-pair {
        margin: 0;
        word-wrap: break-word;
        white-space: normal;
    }

    .request-detail, .response-detail, .message-warp {
        border: 1px solid #eeeeee;
        border-radius: 2px;
        /*margin-bottom: 20px;*/
    }

    .message-list {
        background-color: #eeeeee;
        padding: 10px;
    }

    .message-detail h5 {
        color: #999999;
    }
</style>
