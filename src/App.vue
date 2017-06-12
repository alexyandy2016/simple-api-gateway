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
                        <span class="absolute-path">{{ content.request.path }}?</span>
                        <span v-for="k,v in content.request.query" class="query-string">{{ v }} {{ k }}</span>
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
                            <p v-for="k,v in content.request.headers" class="key-pair"><strong>{{ v }}: </strong>{{ k }}
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
                            <p v-for="k,v in content.response.headers" class="key-pair"><strong>{{ v }}: </strong>{{ k
                                }}
                            </p>
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
            return {
                "contents": [{
                    "request": {
                        "path": "/api/QACenterContacts/CallForAnswer",
                        "method": "GET",
                        "query": {
                            "operateType": "more",
                            "status": "1",
                            "pageIndex": "1",
                            "createDateTime": "2016-12-25",
                            "pageSize": "10"
                        },
                        "body": {},
                        "request_id": "d190b7efea134e4a9445e985156cd8b0",
                        "headers": {
                            "connection": "keep-alive",
                            "accept": "*/*",
                            "userpwd": "passwd789",
                            "cache-control": "no-cache",
                            "postman-token": "44144507-6746-43de-b4ef-ea8cb7beaf34",
                            "accept-encoding": "gzip, deflate",
                            "host": "192.168.8.211:8000",
                            "userid": "80000055",
                            "user-agent": "PostmanRuntime/3.0.11-hotfix.2"
                        }
                    },
                    "response": {
                        "status": 200,
                        "body": {
                            "timeFlag": "2016-12-25 00:00:00.000",
                            "NewTotalGold": "0",
                            "status": "0",
                            "RecordCount": "0",
                            "message": "无相关信息!",
                            "userInfo": {}
                        },
                        "headers": {
                            "Date": "Mon, 15 May 2017 09:39:12 GMT",
                            "Content-Type": "text/plain; charset=utf-8",
                            "X-AspNet-Version": "4.0.30319",
                            "Pragma": "no-cache",
                            "X-DJT-JSONFormat": "norm",
                            "X-Powered-By": "ASP.NET",
                            "Content-Length": "184",
                            "Cache-Control": "no-cache",
                            "Expires": "-1",
                            "Server": "Microsoft-IIS/8.5"
                        }
                    }
                }, {
                    "request": {
                        "path": "/api/QACenterContacts/CallForAnswer",
                        "method": "GET",
                        "query": {
                            "operateType": "more",
                            "status": "1",
                            "pageIndex": "1",
                            "createDateTime": "2016-12-25",
                            "pageSize": "10"
                        },
                        "body": {},
                        "request_id": "d190b7efea134e4a9445e985156cd8b0",
                        "headers": {
                            "connection": "keep-alive",
                            "accept": "*/*",
                            "userpwd": "passwd789",
                            "cache-control": "no-cache",
                            "postman-token": "44144507-6746-43de-b4ef-ea8cb7beaf34",
                            "accept-encoding": "gzip, deflate",
                            "host": "192.168.8.211:8000",
                            "userid": "80000055",
                            "user-agent": "PostmanRuntime/3.0.11-hotfix.2"
                        }
                    },
                    "response": {
                        "status": 200,
                        "body": {
                            "timeFlag": "2016-12-25 00:00:00.000",
                            "NewTotalGold": "0",
                            "status": "0",
                            "RecordCount": "0",
                            "message": "无相关信息!",
                            "userInfo": {}
                        },
                        "headers": {
                            "Date": "Mon, 15 May 2017 09:39:12 GMT",
                            "Content-Type": "text/plain; charset=utf-8",
                            "X-AspNet-Version": "4.0.30319",
                            "Pragma": "no-cache",
                            "X-DJT-JSONFormat": "norm",
                            "X-Powered-By": "ASP.NET",
                            "Content-Length": "184",
                            "Cache-Control": "no-cache",
                            "Expires": "-1",
                            "Server": "Microsoft-IIS/8.5"
                        }
                    }
                }]
            }
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
