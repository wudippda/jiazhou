import { baseUrl } from '../../config/index'
import $ from 'jquery'

var ibm = 'http://192.168.1.150:5000/'

export default async(type = 'GET', url = '', data = null, method = 'normal') => {
    type = type.toUpperCase()

    if (method === 'ibm') {
        url = ibm + url
        console.log('hehe')
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
                timeout: 1000000
            }).done(res => {
                resolve(res)
            }).catch(err => {
                resolve(err)
            })
        }
    })
}