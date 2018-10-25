import Vue from 'vue'
import Router from 'vue-router'
import Login from '@/components/LoginPage'
import Home from '@/components/HomePage'
import Dashboard from '@/components/DashboardPage'
import HousePage from '@/components/HousePage'
import EmailSettingPage from '@/components/EmailSettingPage'
import ParsingPage from '@/components/ParsingPage'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '/',
            redirect: '/parsingPage/CN'
        },
        {
            path: '/login',
            name: '',
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
                    path: '/houses/:lan',
                    name: 'housePage',
                    component: HousePage
                },
                {
                    path: '/emailSetting/:lan',
                    name: 'emailSetting',
                    component: EmailSettingPage
                },
                {
                    path: '/parsingPage/:lan',
                    name: 'parsingPage',
                    component: ParsingPage
                }
            ]
        }
    ]
})