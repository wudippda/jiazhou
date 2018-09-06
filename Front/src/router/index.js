import Vue from 'vue'
import Router from 'vue-router'
import Login from '@/components/LoginPage'
import Home from '@/components/HomePage'
import Dashboard from '@/components/DashboardPage'
import HousePage from '@/components/HousePage'
import EmailSettingPage from '@/components/EmailSettingPage'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '/',
            redirect: '/home'
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
                    path: '/houses',
                    name: 'housePage',
                    component: HousePage
                },
                {
                    path: '/emailSetting',
                    name: 'emailSetting',
                    component: EmailSettingPage
                }
            ]
        }
    ]
})