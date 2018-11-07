import fetch from './fetch'

var register = (email, name, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd, name: name }, 'p')

var getEmailSetting = () => fetch('GET', 'email_setting/get_setting', {})

var updateEmailSetting = (options) => fetch('POST', 'email_setting/update_setting', { options: options }, 'p')

var uploadExcelFile = (file) => fetch('POST', 'housing_report/upload_report', { upload: file }, 'upload', 'progress')

var getReports = (pageId) => fetch('GET', 'housing_report/list_report?page=' + pageId)

var deleteReport = (reportId) => fetch('POST', 'housing_report/delete_report', { id: reportId }, 'upload')

var getHouseOwners = (pageId) => fetch('GET', 'detail_list/list_user?page=' + pageId)

var getDetailByUserId = (userId) => fetch('GET', 'detail_list/find?userId=' + userId)

var getUsers = (pageId) => fetch('GET', 'detail_list/list_user?page=' + pageId)

var getTenantsAndPeroperty = (userId) => fetch('POST', 'detail_list/find', { userId: userId }, 'upload')

var createEmailJob = (name, type, from, to, config) => fetch('POST', 'email_job/create_job', { job_name: name, job_type: type, from: from, to: to, config, config }, 'upload')

var updateEmailJob = (id, name, type, from, to, config) => fetch('POST', 'email_job/update_job', { id: id, job_name: name, job_type: type, from: from, to: to, config, config }, 'upload')

var getEmailJobs = (pageId) => fetch('GET', 'email_job/list_job?page=' + pageId)

var deleteEmailJob = (emailId) => fetch('POST', 'email_job/delete_job', { id: emailId }, 'upload')

var startEmailJob = (jobId) => fetch('POST', 'email_job/start_job', { id: jobId }, 'upload')

var stopEmailJob = (jobId) => fetch('POST', 'email_job/stop_job', { id: jobId }, 'upload')

var getJobHistory = (pageId, id) => fetch('GET', 'email_job/list_job_history?page=' + pageId + '&id=' + id)

// For jupyter demo
// var createUser = (email, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd }, 'p')

var login = (email, pwd) => fetch('POST', 'users/login', { email: email, pwd: pwd }, 'p')

// var allocateDocker = (username, pwd) => fetch('POST', 'terminal', { user_id: username, dataset_id: 1, pwd: pwd }, 'ibm')

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
    getReports,
    createEmailJob,
    updateEmailJob,
    getEmailJobs,
    deleteEmailJob,
    startEmailJob,
    stopEmailJob,
    getJobHistory
    // createUser,
    // allocateDocker
}