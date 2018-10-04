import fetch from './fetch'

var login = (email, pwd) => fetch('POST', 'users/login', { email: email, pwd: pwd }, 'upload')

var register = (email, name, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd, name: name }, 'upload')

var getEmailSetting = () => fetch('GET', 'email_setting/get_setting', {})

var updateEmailSetting = (options) => fetch('POST', 'email_setting/update_setting', { options: options }, 'upload')

export {
    login,
    register,
    getEmailSetting,
    updateEmailSetting
}