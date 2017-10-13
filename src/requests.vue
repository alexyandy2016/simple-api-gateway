<template>
    <div class="container-fluid" id="app">
        <div class="row">
            <div v-for="client in clients" class="message-warp">
                <div class="message-title">
                    <h5>CLIENT : {{ client.client }}</h5>
                </div>
                <div v-for="req in client.requests" class="message-list">
                    <div class="row">
                        <div class="col-md-10"><h5>URI : {{ req.date }}</h5></div>
                    </div>
                </div>
            </div>
        </div>
        <div v-for="req in requests" class="message-warp">
            <div class="message-title">
                <H5>REQUEST ID : {{ req.request_id.toUpperCase() }}</H5>
            </div>
            <div class="message-list">
                <div class="row">
                    <div class="col-md-10">
                        <span class="method">{{ req.request.method }}</span>
                        <span class="absolute-path">{{ req.request.path }}?</span
                        ><span v-for="(k,v,index) in req.request.query" class="query-string">{{ v }}={{ k
                        }}&</span>
                    </div>
                    <div class="col-md-2">
                        <span class="request-time">{{ req.response.Date }}</span>
                        <span class="request-from">From 192.168.100.100</span>
                    </div>
                </div>
            </div>
            <div class="message-detail">
                <div class="request-detail">
                    <div class="row">
                        <div class="col-md-4">
                            <h5>FORM/POST PARAMETERS</h5>
                            <em v-if="JSON.stringify(req.request.body) == '{}'">None</em>
                            <p v-else v-for="k,v in req.request.body" class="key-pair">
                                <strong>{{ v }}: </strong>{{ k }}
                            </p>
                            <h5>QUERY STRING</h5>
                            <em v-if="JSON.stringify(req.request.query) == '{}'">None</em>
                            <p v-else v-for="k,v in req.request.query" class="key-pair">
                                <strong>{{ v }}: </strong>{{ k }}
                            </p>
                        </div>
                        <div class="col-md-8">
                            <h5>HEADERS</h5>
                            <p v-for="k,v in req.request.headers" class="key-pair"><strong>{{ v
                                }}: </strong>{{ k }}
                            </p>
                        </div>
                    </div>
                    <h5>RAW BODY</h5>
                    <div class="request-body">
                        <em v-if="JSON.stringify(req.request.body) == '{}'">None</em>
                        <p v-else>{{ req.request.body }}</p>
                    </div>
                </div>
                <div class="response-detail">
                    <h5>RESPONSE</h5>
                    <div class="row">
                        <div class="col-md-4">
                            <span class="resp-status">STATUS <strong>{{ req.response.status }}</strong></span>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <h5>HEADERS</h5>
                            <p v-for="k,v in req.response.headers" class="key-pair"><strong>{{ v }}: </strong>{{ k
                                }}</p>
                        </div>
                        <div class="col-md-8">
                            <h5>BODY</h5>
                            <span class="body">{{ JSON.parse(req.response.body) }}</span>
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
            return {
                clients: [],
                requests: []
            }
        },
        mounted: function () {
            this.getClientsList();
        },
        methods: {
            getRequestsList(uri) {
                this.axios.get(uri)
                    .then(response => {
                        this.requests = response.data;
                    })
            },
            getClientsList() {
                this.axios.get("/requests")
                    .then(response => {
                        this.clients = response.data;
                    })
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
