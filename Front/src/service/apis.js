import fetch from './fetch'

var login = (email, pwd) => fetch('POST', 'users/login', { email: email, pwd: pwd }, 'upload')

var register = (email, name, pwd) => fetch('POST', 'users/create', { email: email, pwd: pwd, name: name }, 'upload')

export {
    login,
    register
}