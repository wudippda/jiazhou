import { baseUrl } from '../../config/index'
import $ from 'jquery'

var ibm = 'http://10.60.42.201/'

export default async(type = 'GET', url = '', data = null, method = 'normal', proId = '') => {
    type = type.toUpperCase()

    if (method === 'ibm') {
        url = ibm + url
        method = 'upload'
    } else {
        url = baseUrl + url
    }

    let queryStr = ''
    if (type === 'GET') {
        if (data !== null) {
            Object.keys(data).forEach(key => {
                queryStr += key + '=' + data[key] + '&'
            })
        }

        if (queryStr !== '') {
            queryStr = queryStr.substr(0, queryStr.lastIndexOf('&'))
            url += '?' + queryStr
        }
    }

    return new Promise((resolve, reject) => {
        if (method === 'normal') {
            $.ajax({
                type: type,
                url: url,
                processData: false,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                // xhrFields: {
                //     withCredentials: true
                // },
                crossDomain: true,
                data: JSON.stringify(data),
                timeout: 10000
            }).done(res => {
                resolve(res)
            }).catch(err => {
                resolve(err)
            })
        } else if (method === 'upload') {
            let formData = new FormData()
            for (let k in data) {
                formData.append(k, data[k])
            }

            $.ajax({
                type: type,
                url: url,
                processData: false,
                contentType: false,
                // xhrFields: {
                //     withCredentials: server == 'base' ? true : false
                // },
                crossDomain: true,
                data: formData,
                timeout: 1000000,
                xhr: function() {
                    let myXhr = $.ajaxSettings.xhr();
                    if (myXhr.upload) {
                        myXhr.upload.addEventListener('progress', function(e) {
                            if (e.lengthComputable) {
                                var percent = Math.floor(e.loaded / e.total * 100);
                                if (percent <= 100) {
                                    // $("#J_progress_bar").progress('set progress', percent);
                                    // $("#J_progress_label").html('已上传：'+percent+'%');
                                    console.log(percent)
                                }
                                if (percent >= 100) {
                                    // $("#J_progress_label").html('文件上传完毕，请等待...');
                                    // $("#J_progress_label").addClass('success');
                                    $(proId).html('100%')
                                    console.log('OK')
                                }
                            }
                        }, false);
                    }
                    return myXhr;
                }
            }).done(res => {
                resolve(res)
            }).catch(err => {
                resolve(err)
            })
        } else if (method === 'p') {
            let formData = new FormData()
            for (let k in data) {
                formData.append(k, data[k])
            }

            $.ajax({
                type: type,
                url: url,
                processData: false,
                contentType: false,
                // xhrFields: {
                //     withCredentials: server == 'base' ? true : false
                // },
                crossDomain: true,
                data: formData,
                timeout: 1000000
            }).done(res => {
                resolve(res)
            }).catch(err => {
                resolve(err)
            })
        }
    })
}