<template>
    <div class="dashboard-container">
        <div style="height: 40px">
            <Breadcrumb class="left">
                <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
            </Breadcrumb>
        </div>
        <Row type="flex" justify="center">
            <Col span="24">
                <Collapse accordion v-model="currentUser" v-if="users.length > 0" @on-change="changeUser">
                    <Panel :name="item.name" v-for="(item,index) in users" :key="index" style="text-align: left">
                        {{item.name}}
                        <div slot="content" class="user-info">
                            <p><Icon type="iphone"></Icon>&nbsp;<span>{{item.phone_number}}</span></p>
                            <p><Icon type="ios-email"></Icon>&nbsp;<span>{{item.email}}</span></p>
                            <p><Icon type="ios-clock"></Icon>&nbsp;<span>{{item.created_at}}</span></p>
                            <br>
                            <Collapse accordion v-model="currentHouse" v-if="item.properties !== undefined">
                                <Panel :name="house.address" v-for="(house, index) in item.properties" :key="index" style="text-align: left">
                                    {{house.address}} &nbsp; {{house.lot}}
                                    <div slot="content" class="user-info">
                                        <p><Icon type="ios-clock"></Icon>&nbsp;<span>{{house.created_at}}</span></p>
                                        <br>
                                    </div>
                                </Panel>
                            </Collapse>
                        </div>
                    </Panel>
                </Collapse>
            </Col>
        </Row>
        <br>
        <Page :total="totalPage" size="small" @on-change="changePage"></Page>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { getUsers, getTenantsAndPeroperty } from '../service/apis'

export default {
    data () {
        return {
            name: 'HousingPage',
            lanDisplay: {},
            languageType: 'CN',
            clientWidth: 0,
            clientHeight: 0,
            isSmall: false,
            users: [],
            currentPage: 1,
            totalPage: 1,
            currentUser: '',
            currentHouse: ''
        }
    },
    methods: {
        changeUser (keys) {
            let userName = keys[0]
        },
        changePage (page) {
            this.currentPage = page
            this.initData(page)
        },
        async initData (page) {
            this.currentHouse = ''
            this.currentUser = ''
            getUsers(page).then(res => {
                console.log('users', res)
                this.users = res.users
                for (let i = 0; i < this.users.length; i++){
                    getTenantsAndPeroperty(this.users[i].id).then(res => {
                        this.users[i]['properties'] = res.properties
                        this.users[i]['tenants'] = res.tenants
                    }).catch(err => {
                        console.error(err)
                    })
                }
                
                this.currentPage = Number.parseInt(res.currentPage)
                this.totalPage = res.totalPage
            }).catch(err => {
                console.error(err)
            })
        }
    },
    created () {
        this.languageType = this.$route.params.lan
        this.lanDisplay = lan

        this.initData(1)
    },
    mounted () {
        // Change title name
        document.title = this.lanDisplay[this.languageType][this.name]['title']
        // Adaptation
        const that = this
        that.clientWidth = document.documentElement.clientWidth
        that.clientHeight = document.documentElement.clientHeight
        window.onresize = function test() {
            that.clientWidth = document.documentElement.clientWidth
            that.clientHeight = document.documentElement.clientHeight
        }
    },
    watch: {
        '$route' (to, from) {
            this.languageType = to.params.lan
            document.title = this.lanDisplay[this.languageType][this.name]['title']
        },
        clientWidth(val) {
            this.clientWidth = val
            
            if (val < 420) {
                this.isSmall = true
            } else {
                this.isSmall = false
            }
        }
    }
}
</script>

<style scoped>
    .dashboard-container {
        margin: 0 auto;
        width: 90%;
        height: 100%;
    }
    .left {
        float: left
    }
    .user-info p {
        margin: 5px;
    }
    .user-info span {
        font-size: 0.8em;
    }
</style>
