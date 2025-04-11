﻿___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "CLIENT",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Matomo Serverside Client for GTM",
  "brand": {
    "id": "brand_dummy",
    "displayName": "",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAADg0lEQVRIie2WXWxURRTHz8ydO/fubru7aWlrv4QW2vIh4AohYDYqLQ8aA5EQnwySGPURNTEmPviiGH0wmuAHBPABQqTGJ2NCaaqGKrYlaa0NJTRtpbvQhPYudW139967e2fm+CJ0d90KD/C28zhn5v+b+Z85J0MQER7moA9VvQwoAx7IYCsFlMLegVj/8Gw2J7Z21OzvagtVGHejmLJyo9+ruQkwK/X1naz9qZV0SMlCE1K9f3ywu2cCAAghQqrIhtov3u16ZFUAAJQ1bX/7lkr8SagGiEApj75qdB0uCSht0Xe9k+d6JgyDmQYzuBbw6X9MJI6cGJIKAaXb+wnevk64H5gBuglUz176On3tp/sF3JhLfdk9ynWN5E36TdY3GD93YQoyc3J2DJiZ5wJhQKYuHk06C/cGIOKnp4etpK1RUhTSGT36zeiVsRinCgqDlLLFZOzH8VP3Bpz/daZ3IGbyEsmnlCylnCPdN9I0REEVqViGeXX+wkxy6P8AiaTz2ZkRggArdFjOyOhN+dX1zZwiI4oAEECTyBlkV0J6wEd/i510xOIKAITPz/4et22t3gSTgigNMTTZPb/1w/ie2WxYILUV7/ur/Rit0et0n89ccOKXb57NX7/8TH+ZnHu9fwRW+4BRYks6tqSNLAEAFOcCACCnWJg5dTyVEb5c8NauZ35uaAowQwNABNi3/oNHw9sKbrDoiY8Tca/ND5wCAazU5NNVakdICVVCHoBTkVF80q61FN342FBNLWdcu3NieSl+IivSBYDzljXupHUk/7qvAAWau6rXbKgWXmkGAQQpWlsHm9bYht+4e1FKmJWZnlroLwCMp1JFThAEm+Chlx+vq/JLVSIfnoebO/TIE7cCQR8tqBkgQKz0VAEgyFiRBgKgVNvba98+tF39B6AUBiv0jw7vfW7nS8AkFO9FgwUKAHtqVvk0TeX1payUW4LBRsaf3712f+c62/XyJdyceO3AlrXNlZHmFxvDm4TK5qkrRo2WqicLANtCoTdbWhDAkdJVKiPlar//vfY2TigAvPPKjmikyXY9NyfcrHCy4oXOtoN7NwKATs3drW+EzUZPOkLlPOUi4s7mgw2Vm+5YnXfqgWSyx7L+9ryOQMWB+vp6c7k/26744eL08NV5TaPRSMOz0RamLddQOpe4ZvXdtmdMFlxXHW0ORZbzUf4XlQFlAPwDXYWGXACj6aEAAAAASUVORK5CYII\u003d"
  },
  "description": "The Matomo Server-Side Client for Google Tag Manager enables you to collect and process analytics data directly through your server-side GTM container before sending it to your Matomo instance.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "jsURL",
    "displayName": "Matomo Javascript URL",
    "simpleValueType": true,
    "help": "The domain to load matomo.js, eg: https://cdn.matomo.cloud/yourdomain.matomo.cloud/",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "REGEX",
        "args": [
          "^https://(.*)"
        ],
        "errorMessage": "The JavaScript domain should start with https"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "domainURL",
    "displayName": "Matomo Domain URL",
    "simpleValueType": true,
    "help": "The domain to send the tracking request, eg https://yourdomain.matomo.cloud/",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "REGEX",
        "args": [
          "^https://(.*)"
        ],
        "errorMessage": "The Matomo domain URL should start with https"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const claimRequest = require('claimRequest');
const getRequestPath = require('getRequestPath');
const sendHttpGet = require('sendHttpGet');
const logToConsole = require('logToConsole');
const setResponseBody = require('setResponseBody');
const setResponseHeader = require('setResponseHeader');
const setResponseStatus = require('setResponseStatus');
const returnResponse = require('returnResponse');
const templateDataStorage = require('templateDataStorage');
const getTimestampMillis = require('getTimestampMillis');
const getRequestMethod = require('getRequestMethod');
const sendHttpRequest = require('sendHttpRequest');
const getRequestBody = require('getRequestBody');
const getRequestHeader = require('getRequestHeader');
const getRequestQueryString = require('getRequestQueryString');

const CACHE_MAX_TIME_MS = 43200000;
const STORED_JS_NAME = 'matomo.js';
const STORED_HEADERS_NAME = 'matomo_js_headers';
const STORED_TIMEOUT_NAME = 'matomo_js_timeout';

const sendCDNResponse = (body, headers, statusCode) => {
    setResponseStatus(statusCode);
    setResponseBody(body);
    if (headers) {
        for (const key in headers) {
            setResponseHeader(key, headers[key]);
        }
    }
    returnResponse();
};

const getJSURL = () => {
    return data.jsURL + (shouldAppendSlashAtTheEnd(data.jsURL) ? '/' : '');
};

const getDomainURL = () => {
    return data.domainURL + (shouldAppendSlashAtTheEnd(data.domainURL) ? '/' : '');
};

const shouldAppendSlashAtTheEnd = (url) => {
    const length = url.length;

    return (url[length - 1] !== '/');
};


const handleMatomoJs = () => {
    const now = getTimestampMillis();
    const storageExpireTime = now - CACHE_MAX_TIME_MS;
    const storedJsBody = templateDataStorage.getItemCopy(STORED_JS_NAME);
    const storedHeaders = templateDataStorage.getItemCopy(STORED_HEADERS_NAME);
    const storedTimeout = templateDataStorage.getItemCopy(STORED_TIMEOUT_NAME);
    if (!storedJsBody || storedTimeout < storageExpireTime) {
        sendHttpGet(getJSURL() + 'matomo.js', {
                timeout: 1500
            })
            .then(result => {
                if (result.statusCode === 200) {
                    templateDataStorage.setItemCopy(STORED_JS_NAME, result.body);
                    templateDataStorage.setItemCopy(STORED_HEADERS_NAME, result.headers);
                    templateDataStorage.setItemCopy(STORED_TIMEOUT_NAME, now);
                }
                sendCDNResponse(result.body, result.headers, result.statusCode);
            });
    } else {
        logToConsole('Cache hit successful, fetching from SGTM storage.');
        sendCDNResponse(
            storedJsBody,
            storedHeaders,
            200
        );
    }
};

const handleMatomoPhp = () => {
    if (getRequestMethod() === 'POST') {
        logToConsole(getRequestBody(), 'getRequestBody');
        const headers = {};
        headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8';
        sendHttpRequest(getDomainURL() + 'matomo.php?' + getRequestQueryString(), {
                method: 'POST',
                timeout: 5000,
                headers: headers,
            }, getRequestBody())
            .then((result) => {
                sendCDNResponse(result.body, result.headers, result.statusCode);
            });
    } else {
        logToConsole(getRequestQueryString(), 'queryString');
        sendHttpGet(getDomainURL() + 'matomo.php?' + getRequestQueryString(), {
                timeout: 5000
            })
            .then(result => {
                sendCDNResponse(result.body, result.headers, result.statusCode);
            });
    }
};

const handleHeatmapConfig = () => {
    sendHttpGet(getDomainURL() + 'plugins/HeatmapSessionRecording/configs.php?' + getRequestQueryString(), {
            timeout: 5000
        })
        .then(result => {
            sendCDNResponse(result.body, result.headers, result.statusCode);
        });
};

const path = getRequestPath();
switch (path) {
    case '/matomo.js':
        claimRequest();
        handleMatomoJs();
        break;

    case '/matomo.php':
        claimRequest();
        handleMatomoPhp();
        break;

    case '/plugins/HeatmapSessionRecording/configs.php':
        claimRequest();
        handleHeatmapConfig();
        break;

    default:
        // Don't claim — let another Client handle
        break;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "return_response",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Should load matomo_js
  code: |
    const mockData = {
      'jsURL': 'https://cdn.matomo.cloud/web.innocraft.cloud/',
      'domainURL': 'https://web.innocraft.cloud/',
    };

    mock('getRequestPath', '/matomo.js');
    // Call runCode to run the template's code.
    runCode(mockData);
    assertApi('claimRequest').wasCalled();
- name: Should track matomo event tracking request via GET
  code: |-
    const mockData = {
      'jsURL': 'https://cdn.matomo.cloud/web.innocraft.cloud/',
      'domainURL': 'https://web.innocraft.cloud/',
    };

    mock('getRequestPath', '/matomo.php');
    mock('getRequestQueryString', 'idsite=1&rec=1&action_name=GTM+Action+Test');
    mock('getRequestMethod', 'GET');


    // Call runCode to run the template's code.
    runCode(mockData);
    assertApi('claimRequest').wasCalled();
- name: Should track matomo event tracking request via POST
  code: |-
    const mockData = {
      'jsURL': 'https://cdn.matomo.cloud/web.innocraft.cloud/',
      'domainURL': 'https://web.innocraft.cloud/',
    };

    mock('getRequestPath', '/plugins/HeatmapSessionRecording/configs.php');
    mock('getRequestQueryString', 'idsite=1&trackerid=h3Moam&url=http%3A%2F%2Flocalhost.demo.com%2Fmtm-serverside-test.html%3Futm_source%3Dfacebook');
    mock('getRequestMethod', 'POST');


    // Call runCode to run the template's code.
    runCode(mockData);
    assertApi('claimRequest').wasCalled();
- name: Should load config for heatmaps
  code: |-
    const mockData = {
      'jsURL': 'https://cdn.matomo.cloud/web.innocraft.cloud/',
      'domainURL': 'https://web.innocraft.cloud/',
    };

    mock('getRequestPath', '/matomo.php');
    mock('getRequestQueryString', 'idsite=1&rec=1&action_name=GTM+Action+Test');
    mock('getRequestMethod', 'GET');

    // Call runCode to run the template's code.
    runCode(mockData);


___NOTES___

Created on 11/4/2025, 8:52:45 am

