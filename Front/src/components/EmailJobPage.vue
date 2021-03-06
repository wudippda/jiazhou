<template>
    <div class="emailjob-container">
        <div style="height: 80px">
            <Breadcrumb class="left">
                <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
            </Breadcrumb>
            <br>
            <br>
            <Button class="left" type="success" shape="circle" size="large" @click="prepareOpenCreateModal">{{lanDisplay[languageType][name]['newJobBtn']}} </Button>
        </div>

        <div>
            <Tabs :value="currentTab" @on-click="changeTab">
                <TabPane :label="lanDisplay[languageType][name]['tabJobLabel']" name="jobs">
                    <Row type="flex" justify="center">
                        <Col span="24">
                            <Card class="for-card" v-for="(item, index) in emailJobList" :key="index">
                                <p slot="title" style="text-align: center">
                                    <Icon type="ionic"></Icon>
                                    {{item.job_name}}
                                </p>

                                <Row type="flex" justify="start" class="card-info">
                                    <Col span="19">
                                        <p>{{lanDisplay[languageType][name]['createTimeLabel']}}:<span>&nbsp;{{item.created_at}}</span></p>
                                        <br>
                                        <p>{{lanDisplay[languageType][name]['statusLabel']}}: 
                                            <Button shape="circle" size="small" type="error" v-if="item.job_status === 'idle'">{{lanDisplay[languageType][name]['idle']}}</Button>
                                            <Button shape="circle" size="small" type="warning" v-if="item.job_status === 'scheduled'">{{lanDisplay[languageType][name]['scheduled']}}</Button>
                                            <Button shape="circle" size="small" type="success" v-if="item.job_status === 'active '">{{lanDisplay[languageType][name]['active']}}</Button>
                                        </p>
                                        <br>
                                        <p>{{lanDisplay[languageType][name]['fromEmailLabel']}}: <span style="font-size: 0.9em">&nbsp;{{item.from}}</span></p>
                                        <br>
                                        <p>{{lanDisplay[languageType][name]['toEmailLabel']}}: <span style="font-size: 0.9em">&nbsp;{{item.to}}</span></p>
                                        <br>
                                        <p>{{lanDisplay[languageType][name]['configLabel']}}: <span style="font-size: 0.9em">&nbsp;{{item.config}}</span></p>
                                        <br>
                                        <p v-if="item.job_status === 'scheduled'">{{lanDisplay[languageType][name]['nextTimeLabel']}}:<span style="font-size: 0.9em">&nbsp;{{item.next_time}}</span></p>
                                        <br>
                                        <a @click="turnToHistory(item)">{{lanDisplay[languageType][name]['historyLink']}}</a>
                                        <Button type="success" shape="circle" icon="play" style="float: left" v-if="item.job_status === 'idle'" @click="startJob(item)"></Button>
                                        <Button type="error" shape="circle" icon="pause" style="float: left" v-if="item.job_status === 'scheduled'" @click="stopJob(item)"></Button>
                                    </Col>
                                </Row>
                                <a href="#" slot="extra" @click.prevent="startUpdateJob(item)" style="margin: 5px !important">
                                    <Icon type="edit"></Icon>
                                </a>
                                
                                <a href="#" slot="extra" @click.prevent="deleteJob(item)">
                                    <Icon type="ios-close-outline"></Icon>
                                </a>
                            </Card>
                        </Col>
                    </Row>
                    <Page :total="emailJobTotalPage * 5" size="small" :current="emailJobCurrentPage" page-size="5" @on-change="emailJobChangePage"></Page>
                </TabPane>

                <TabPane :label="lanDisplay[languageType][name]['tabHistoryLabel']" name="history">
                    <Row type="flex" justify="center">
                        <Table :columns="columns" :data="histories"></Table>
                    </Row>
                    <br>
                    <Page :total="historyTotalPage * 5" size="small" :current="historyCurrentPage" page-size="5" @on-change="historyChangePage"></Page>
                </TabPane>
            </Tabs>
            <br><br>
        </div>

        <Modal v-model="createModal" width="500">
            <p slot="header" style="text-align:center">
                <span>{{lanDisplay[languageType][name]['newJobForm']['header']}}</span>
            </p>
            <div style="text-align:center">
                <Form ref="emailJobForm" :model="newEmailJob" :label-width="80" style="width: 75%;margin: 0 auto" :rules="ruleValidate">
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['jobName']" prop="jobName">
                        <Input v-model="newEmailJob.jobName" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['jobType']" prop='jobType'>
                        <Select v-model="newEmailJob.jobType" placeholder='...'>
                            <Option v-for="item in languageType === 'CN' ? jobTypeListCN : jobTypeListEN" :value="item.value" :key="item.value">{{ item.label }}</Option>
                        </Select>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['from']" prop="from">
                        <Input v-model="newEmailJob.from" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['to']">
                        <Select v-model="newEmailJob.to" multiple placeholder='...'>
                            <Option v-for="item in userList" :value="item.value" :key="item.value">{{ item.label }}</Option>
                        </Select>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['config']" prop="config">
                        <Input v-model="newEmailJob.config" placeholder="..."></Input>
                    </FormItem>
                </Form>
            </div>
            <div slot="footer">
                <Button type="primary" size="large" long :loading="createLoading" @click="createNewEmailJob">{{lanDisplay[languageType][name]['formSubmit']}}</Button>
            </div>
    </Modal>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { uploadExcelFile, getReports, deleteReport, getUsers, createEmailJob, getEmailJobs, deleteEmailJob, startEmailJob, stopEmailJob, updateEmailJob, getJobHistory } from '../service/apis'

export default {
    data() {
        return {
            name: 'EmailJobPage',
            lanDisplay: {},
            languageType: 'CN',
            clientWidth: 0,
            clientHeight: 0,
            isSmall: false,
            currentPage: 1,
            totalPage: 1,
            createModal: false,
            showCreateModal: true,
            createLoading: false,
            newEmailJob: {
                jobName: '',
                jobType: '',
                from: '',
                to: [],
                config: '{"cron": "* * * * *", "timezone": "Beijing"}'
            },
            jobTypeListEN: [
                {
                    value: 'now',
                    label: 'Now'
                },
                {
                    value: 'delay',
                    label: 'Delay'
                },
                {
                    value: 'schedule',
                    label: 'Schedule'
                }
            ],
            jobTypeListCN: [
                {
                    value: 'now',
                    label: '即使任务'
                },
                {
                    value: 'delay',
                    label: '延时任务'
                },
                {
                    value: 'schedule',
                    label: '计划任务'
                }
            ],
            ruleValidate: {
                jobName: [
                    { required: true, message: 'Job name cannot be empty', trigger: 'blur'}
                ],
                jobType: [
                    { required: true, message: 'Job type cannot be empty', trigger: 'blur' }
                ],
                from: [ 
                    { required: true, message: 'Mailbox cannot be empty', trigger: 'blur' },
                    { type: 'email', message: 'Incorrect email format', trigger: 'blur' }
                ],
                config: [
                    { required: true, message: 'Config cannnot be empty', trigger: 'blur'}
                ]
            },
            userList: [],
            emailJobList: [],
            emailJobTotalPage: 1,
            emailJobCurrentPage: 1,
            historyTotalPage: 1,
            historyCurrentPage: 1,
            selectItem: null,
            mode: 'create',
            currentTab: 'jobs',
            columns: [
                {
                    title: 'Execution Time',
                    key: 'execution_time'
                },
                {
                    title: 'Status',
                    key: 'status'
                },
                {
                    title: 'Success Time',
                    key: 'success_time'
                },
                {
                    title: 'Fail Time',
                    key: 'fail_time'
                },
                {
                    title: 'Success to List',
                    key: 'success_to_list'
                },
                {
                    title: 'Fail To List',
                    key: 'fail_to_list'
                },
                {
                    title: 'Fail Errors',
                    key: 'fail_errors'
                },
                {
                    title: 'Create At',
                    key: 'create_at'
                },
                {
                    title: 'Updated At',
                    key: 'updated_at'
                }
            ],
            histories: []
        }
    },
    methods: {
        turnToHistory (item) {
            console.log(item.id)
            this.selectItem = item
            this.initData(1, 'history', item.id) 
            this.currentTab = 'history'           
        },
        prepareOpenCreateModal () {
            this.clearForm()
            this.mode='create'
            this.createModal=true
        },
        changeTab (name) {
            this.currentTab = name
            this.initData(1, name)
        },
        historyChangePage (page) {
            console.log(page)
            this.historyCurrentPage = page
            this.initData(page, 'history', this.selectItem.id)
        },
        emailJobChangePage (page) {
            this.emailJobCurrentPage = page
            this.initData(page, 'jobs')
        },
        deleteJob (item) {
            if (item.job_status === 'active') {
                this.$Notice.error({
                    title: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['desc']
                })
                return
            }
            deleteEmailJob(item.id).then(res => {
                console.log(res)
                if (res['success'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['deleteSuccessMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['deleteSuccessMsg']['desc']
                    })
                    this.initData(1, 'jobs')
                } else {
                    this.$Notice.error({
                        title: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['desc'] + ':' + res['errors']['job_status']
                    })
                }
            }).catch(err => {
                console.error(err)
                this.$Notice.error({
                    title: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['deleteFailMsg']['desc']
                })
            })
        },
        startUpdateJob (item) {
            this.selectItem = item
            this.mode = 'update'
            this.newEmailJob.jobName = item.job_name
            this.newEmailJob.jobType = item.job_type
            this.newEmailJob.config = item.config
            this.newEmailJob.from = item.from
            this.newEmailJob.to = item.to.split(";")
            this.createModal = true
        },
        goUpdateEmailJob (toUsers) {
            this.createLoading = true
            updateEmailJob(this.selectItem.id, this.newEmailJob.jobName, this.newEmailJob.jobType, this.newEmailJob.from, toUsers, this.newEmailJob.config).then(res => {
                if (res['success'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['updateJobSuccessMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['updateJobSuccessMsg']['desc']
                    })
                    this.clearForm()
                    this.createModal = false
                    this.initData(1, 'jobs')
                } else {
                    this.$Notice.error({
                        title: this.lanDisplay[this.languageType][this.name]['updateJobFailMsg']['title'],
                        desc: res['errors']
                    })
                }
                this.createLoading = false
            }).catch(err => {
                console.log(err)
                this.$Notice.error({
                    title: this.lanDisplay[this.languageType][this.name]['updateJobFailMsg']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['updateJobFailMsg']['desc']
                })
                this.createLoading = false
            })
        },
        startJob (item) {
            startEmailJob(item.id).then(res => {
                console.log(res)
                if (res['success'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['startJobSuccessMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['startJobSuccessMsg']['desc']
                    })
                    this.initData(1, 'jobs')
                } else {
                    this.$Notice.error ({
                        title: this.lanDisplay[this.languageType][this.name]['startJobFailMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['startJobFailMsg']['desc']
                    })
                }
            }).catch(err => {
                console.error(err)
                this.$Notice.error ({
                    title: this.lanDisplay[this.languageType][this.name]['startJobFailMsg']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['startJobFailMsg']['desc']
                })
            })
        },
        stopJob (item) {
            stopEmailJob(item.id).then(res => {
                console.log(res)
                if (res['success'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['stopJobSuccessMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['stopJobSuccessMsg']['desc']
                    })
                    this.initData(1, 'jobs')
                } else {
                    this.$Notice.error ({
                        title: this.lanDisplay[this.languageType][this.name]['stopJobFailMsg']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['stopJobFailMsg']['desc']
                    })
                }
            }).catch(err => {
                console.error(err)
                this.$Notice.error ({
                    title: this.lanDisplay[this.languageType][this.name]['stopJobFailMsg']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['stopJobFailMsg']['desc']
                })
            })
        },
        createNewEmailJob () {
            this.$refs['emailJobForm'].validate((valid) => {
                if (valid) {
                    let toUsers = ''
                    for (let i = 0; i < this.newEmailJob.to.length; i++) {
                        toUsers += this.newEmailJob.to[i]
                        if (i !== this.newEmailJob.to.length - 1) {
                            toUsers += ';'
                        }
                    }

                    if (this.mode === 'update') {
                        this.goUpdateEmailJob(toUsers)
                        return
                    }
                    this.createLoading = true
                    createEmailJob(this.newEmailJob.jobName, this.newEmailJob.jobType, this.newEmailJob.from, toUsers, this.newEmailJob.config).then(res => {
                        console.log(res)
                        if (res['success'] === true) {
                            this.$Notice.success({
                                title: this.lanDisplay[this.languageType][this.name]['createSuccessMsg']['title'],
                                desc: this.lanDisplay[this.languageType][this.name]['createSuccessMsg']['desc']
                            })
                            this.clearForm()
                            this.createModal = false
                            this.initData(1, 'jobs')
                        } else {
                            this.$Notice.error({
                                title: this.lanDisplay[this.languageType][this.name]['createFailMsg']['title'],
                                desc: res['errors']
                            })
                        }
                        this.createLoading = false
                    }).catch(err => {
                        console.error(err)
                        this.$Notice.error({
                            title: this.lanDisplay[this.languageType][this.name]['createFailMsg']['title'],
                            desc: this.lanDisplay[this.languageType][this.name]['createFailMsg']['desc']
                        })
                        this.createLoading = false
                    })
                } else {
                    this.$Notice.error(this.lanDisplay[this.languageType][this.name]['formError']);
                }
            })
        },
        clearForm () {
            this.newEmailJob = {
                jobName: '',
                jobType: '',
                from: '',
                to: [],
                config: '{"cron": "* * * * *", "timezone": "Beijing"}'
            }
        },
        async getAllUsers () {
            getUsers(1).then(res => {
                console.log('user', res)
                let totalPage = res['totalPage']

                for (let i = 0; i < res['users'].length; i++) {
                    this.userList.push({
                        value: res['users'][i]['email'],
                        label: res['users'][i]['name']
                    })
                }

                for (let i = 2; i <= totalPage; i++) {
                    getUsers(i).then(res => {
                        for (let i = 0; i < res['users'].length; i++) {
                            this.userList.push({
                                value: res['users'][i]['email'],
                                label: res['users'][i]['name']
                            })
                        }
                    }).catch(err => {})
                }

            }).catch(err => {
                console.error(err)
            })
        },
        async initData (page, type, id) {
            if (type === 'jobs') {
                    getEmailJobs(page).then(res => {
                        console.log('Email jobs', res)
                        this.emailJobList = res.jobs
                        this.emailJobTotalPage = res.totalPage
                        this.emailJobCurrentPage = Number.parseInt(res.currentPage)

                        for (let i = 0; i < this.emailJobList.length; i++) {
                            console.log(this.emailJobList[i])
                            if (this.emailJobList[i]['next_time'] !== null)
                                this.emailJobList[i]['next_time'] = this.emailJobList[i]['next_time'].replace(/(\w+)-(\w+)-(\w+)T(\w+):(\w+):(\w+).(\w+)*/g, '$1-$2-$3, $4:$5:$6')
                        }
                    }).catch(err => {
                        console.error(err)
                    })
            } else if (type === 'history') {
                getJobHistory(page, id).then(res => {
                    console.log(res)
                    this.historyCurrentPage = Number.parseInt(res.currentPage)
                    this.historyTotalPage = res.totalPage

                    this.histories = []
                    for (let i = 0; i < res.histories.length; i++) {
                        this.histories.push({
                            execution_time: res.histories[i]['execution_time'].replace(/(\w+)-(\w+)-(\w+)T(\w+):(\w+):(\w+).(\w+)*/g, '$1-$2-$3, $4:$5:$6'),
                            status: res.histories[i]['job_history_status'],
                            success_time: res.histories[i]['success_to'],
                            fail_time: res.histories[i]['fail_to'],
                            success_to_list: res.histories[i]['success_to_list'],
                            fail_to_list: res.histories[i]['fail_to_list'],
                            fail_errors: res.histories[i]['fail_errors'],
                            create_at: res.histories[i]['created_at'].replace(/(\w+)-(\w+)-(\w+)T(\w+):(\w+):(\w+).(\w+)*/g, '$1-$2-$3, $4:$5:$6'),
                            updated_at: res.histories[i]['updated_at'].replace(/(\w+)-(\w+)-(\w+)T(\w+):(\w+):(\w+).(\w+)*/g, '$1-$2-$3, $4:$5:$6')
                        })
                    }
                }).catch(err => {
                    console.error(err)
                })
            }
            
        }
    },
    created () {
        this.languageType = this.$route.params.lan
        this.lanDisplay = lan

        this.initData(1, 'jobs')
        this.getAllUsers()
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
    .emailjob-container {
        width: 90%;
        height: 100%;
        margin: 0 auto;
    }
    .left {
        float: left;
    }
    .for-card {
        width: 100%;
        margin-bottom: 20px;
    }
    .for-card p {
        font-size: 1.1em;
        color: #1c2438;
        font-weight: 700;
        text-align: left;
    }
    .card-info {
        margin: 15px;
    }
    .card-info div {
        float: left;
        margin-bottom: 5px;
    }
</style>
