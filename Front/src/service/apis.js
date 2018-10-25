import fetch from './fetch'

var register = (email, name, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd, name: name }, 'p')

var getEmailSetting = () => fetch('GET', 'email_setting/get_setting', {})

var updateEmailSetting = (options) => fetch('POST', 'email_setting/update_setting', { options: options }, 'p')

var uploadExcelFile = (file) => fetch('POST', 'excel_report/upload_report', { upload: file }, 'upload', 'progress')

var getReports = (pageId) => fetch('GET', 'excel_report/list_report?page=' + pageId)

var deleteReport = (reportId) => fetch('POST', 'excel_report/delete_report', { id: reportId }, 'upload')

var getHouseOwners = (pageId) => fetch('GET', 'detail_list/list_user?page=' + pageId)

var getDetailByUserId = (userId) => fetch('GET', 'detail_list/find?userId=' + userId)

var getUsers = (pageId) => fetch('GET', 'detail_list/list_user?page=' + pageId)

var getTenantsAndPeroperty = (userId) => fetch('GET', 'detail_list/find?userId=' + userId)

// For jupyter demo
var createUser = (email, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd }, 'p')

var login = (email, pwd) => fetch('POST', 'users/login', { email: email, pwd: pwd }, 'p')

var allocateDocker = (username, pwd) => fetch('POST', 'terminal', { user_id: username, dataset_id: 1, pwd: pwd }, 'ibm')

export {
    login,
    register,
    getEmailSetting,
    updateEmailSetting,
    uploadExcelFile,
    deleteReport,
    getHouseOwners,
    getDetailByUserId,
    getUsers,
    getTenantsAndPeroperty,
    createUser,
    getReports,
    allocateDocker
}