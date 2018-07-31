import Vue from 'vue'
import Router from 'vue-router'
import Login from '@/components/LoginPage'
import Home from '@/components/HomePage'
import Dashboard from '@/components/DashboardPage'
import TablePage from '@/components/TablePage'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '/',
            redirect: '/login'
        },
        {
            path: '/login',
            name: 'login',
            components: {
                mainPage: Login
            }
        },
        {
            path: '/home',
            name: 'home',
            components: {
                mainPage: Home
            },
            children: [{
                    path: '/dashboard/:userId',
                    name: 'dashboard',
                    component: Dashboard
                },
                {
                    path: '/table',
                    name: 'table',
                    component: TablePage
                }
            ]
        }
    ]
})