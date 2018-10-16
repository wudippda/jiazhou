import fetch from './fetch'

var register = (email, name, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd, name: name }, 'upload')

var getEmailSetting = () => fetch('GET', 'email_setting/get_setting', {})

var updateEmailSetting = (options) => fetch('POST', 'email_setting/update_setting', { options: options }, 'upload')

var uploadExcelFile = (file) => fetch('POST', 'excel_report/upload_report', { upload: file }, 'upload')

var getReports = (pageId) => fetch('GET', 'excel_report/list_report?page=' + pageId)

// For jupyter demo
var createUser = (email, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd }, 'upload')

var login = (email, pwd) => fetch('POST', 'users/login', { email: email, pwd: pwd }, 'upload')

export {
    login,
    register,
    getEmailSetting,
    updateEmailSetting,
    uploadExcelFile,
    createUser,
    getReports
}