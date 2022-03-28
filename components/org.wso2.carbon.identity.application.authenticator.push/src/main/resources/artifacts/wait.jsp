<%--
  ~ Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~ WSO2 Inc. licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file except
  ~ in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~ http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  ~
  --%>

<%@ taglib prefix = "s" uri = "http://java.sun.com/jsp/jstl/core" %>
<%@ page language = "java" contentType = "text/html; charset=UTF-8" pageEncoding = "UTF-8" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<jsp:directive.include file="includes/init-url.jsp"/>

<html>
<head>
    <meta http-equiv = "X-UA-Compatible" content = "IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WSO2 Identity Server</title>
    <meta charset="<%=StandardCharsets.UTF_8.name()%>">

    <link rel="icon" href="images/favicon.png" type="image/x-icon"/>
    <link href="libs/bootstrap_3.3.5/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/Roboto.css" rel="stylesheet">
    <link href="css/custom-common.css" rel="stylesheet">
    <link href="css/loading1.css" rel="stylesheet">

    <script language="JavaScript" type="text/javascript" src="libs/jquery_3.4.1/jquery-3.4.1.js"></script>
    <script language="JavaScript" type="text/javascript" src="libs/bootstrap_3.4.1/js/bootstrap.min.js"></script>

    <header class="header header-default">
        <div class="container-fluid"><br></div>
        <div class="container-fluid">
            <div class="pull-left brand float-remove-xs text-center-xs">
                <a href="#">
                    <img src="images/logo-inverse.svg" alt="WSO2" title="WSO2" class="logo">
                    <h1><em>Identity Server</em></h1>
                </a>
            </div>
        </div>
    </header>
</head>
<body>
<h2>Check your mobile device</h2>
<p> 1. Click the notification received from WSO2 Verify</p>
<p> 2. Click "Allow" and User your fingerprint to login</p>
<br>
<div class="screenshot">
    <img src="images/biometricauthentication.gif" class="animation" class="img-fluid">
</div>
<form id="toCommonAuth" action="<%=commonauthURL%>" method="POST" style="display:none;">
    <input type="hidden" name="ACTION" value="WaitResponse"/>
    <input type="hidden" id="sessionDataKey" name="sessionDataKey">
    <input type="hidden" id="proceedAuthorization" name="proceedAuthorization">
</form>
</body>
<script type="text/javascript">
    let i = 0;
    let sessionDataKey;
    const refreshInterval = 1000;
    const timeout = 900000;
    let pushEndpointWithQueryParams = "<%=PushAuthenticatorConstants.PUSH_ENDPOINT +
     PushAuthenticatorConstants.POLLING_QUERY_PARAMS%>";
    const GET = 'GET';

    $(document).ready(function () {
        var startTime = new Date().getTime();
        console.log("Start time: "+ startTime);

        const intervalListener = window.setInterval(function () {
            checkWaitStatus();
            i++;
            console.log("Polled ${i} times")
        }, refreshInterval);

        function checkWaitStatus() {
            const now = new Date().getTime();
            if ((startTime + timeout) < now) {
                window.clearInterval(intervalListener);
                window.location.replace("retry.do?statusMsg=push.auth.timed.out.message&status=push.auth.timed.out");
            }

            const urlParams = new URLSearchParams(window.location.search);
            sessionDataKey = urlParams.get('sessionDataKey');
            $.ajax(pushEndpointWithQueryParams + sessionDataKey, {
                async: false,
                cache : false,
                method: GET,
                success: function (res) {
                    handleStatusResponse(res);
                },
                error: function () {

                    checkWaitStatus();
                },
                failure: function () {
                    window.clearInterval(intervalListener);
                    window.location.replace("/retry.do");
                }
            });
        }

        function handleStatusResponse(res) {

                    if ((res.status) === "<%=PushAuthenticatorConstants.COMPLETED%>") {
                        document.getElementById("proceedAuthorization").value = "proceed";
                        document.getElementById("sessionDataKey").value = sessionDataKey;
                        continueAuthentication(res);
                    } else {
                        checkWaitStatus();
                    }
                }

                function continueAuthentication(res) {
                        console.log("Continuing Auth request");

                        window.clearInterval(intervalListener);
                        document.getElementById("toCommonAuth").submit();
                    }

    });
</script>
</html>
