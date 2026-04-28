/**
 * 从url中拿出参数对。
 */
function getParams() {
    var params = {};
    window.location.search.substring(1)
        .split('&')
        .forEach(function (param) {
            var pair = param.split('=');
            params[pair[0]] = decodeURIComponent(pair[1]);
        });
    return params;
}