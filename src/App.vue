<template>
    <div class="container-fluid" id="app">
        <div v-for="content in contents" class="message-warp">
            <div class="message-title">
                <H5>REQUEST ID : {{ content.request.request_id.toUpperCase() }}</H5>
            </div>
            <div class="message-list">
                <div class="row">
                    <div class="col-md-10">
                        <span class="method">{{ content.request.method }}</span>
                        <span class="absolute-path">{{ content.request.path }}?</span
                        ><span v-for="(k,v,index) in content.request.query" class="query-string">{{ v }}={{ k
                        }}&</span>
                    </div>
                    <div class="col-md-2">
                        <span class="request-time"></span>
                        <span class="request-from">From 192.168.100.100</span>
                    </div>
                </div>
            </div>
            <div class="message-detail">
                <div class="request-detail">
                    <div class="row">
                        <div class="col-md-4">
                            <h5>FORM/POST PARAMETERS</h5>
                            <em v-if="JSON.stringify(content.request.body) == '{}'">None</em>
                            <p v-else v-for="k,v in content.request.body" class="key-pair">
                                <strong>{{ v }}: </strong>{{ k }}
                            </p>
                            <h5>QUERY STRING</h5>
                            <em v-if="JSON.stringify(content.request.query) == '{}'">None</em>
                            <p v-else v-for="k,v in content.request.query" class="key-pair">
                                <strong>{{ v }}: </strong>{{ k }}
                            </p>
                        </div>
                        <div class="col-md-8">
                            <h5>HEADERS</h5>
                            <p v-for="k,v in content.request.headers" class="key-pair"><strong>{{ v
                                }}: </strong>{{ k }}
                            </p>
                        </div>
                    </div>
                    <h5>RAW BODY</h5>
                    <div class="request-body">
                        <em v-if="JSON.stringify(content.request.body) == '{}'">None</em>
                        <p v-else>{{ content.request.body }}</p>
                    </div>
                </div>
                <div class="response-detail">
                    <h5>RESPONSE</h5>
                    <div class="row">
                        <div class="col-md-4">
                            <span class="resp-status">STATUS <strong>{{ content.response.status }}</strong></span>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <h5>HEADERS</h5>
                            <p v-for="k,v in content.response.headers" class="key-pair"><strong>{{ v }}: </strong>{{ k }}</p>
                        </div>
                        <div class="col-md-8">
                            <h5>BODY</h5>
                            <span class="body">{{ content.response.body }}</span>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</template>

<script>
    export default {
        name: 'app',
        data() {
            let json = require('./assets/data.json');
            return json
        },
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
