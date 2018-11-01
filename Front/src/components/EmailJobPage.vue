<template>
    <div class="emailjob-container">
        <div style="height: 80px">
            <Breadcrumb class="left">
                <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
            </Breadcrumb>
            <br>
            <br>
            <Button class="left" type="success" shape="circle" size="large" :loading="isUploading" @click="createModal=true">{{lanDisplay[languageType][name]['title']}} </Button>
        </div>

        <div>
            <Tabs value="jobs">
                <TabPane :label="lanDisplay[languageType][name]['tabJobLabel']" name="jobs">
                    
                </TabPane>

                <TabPane :label="lanDisplay[languageType][name]['tabHistoryLabel']" name="history">

                </TabPane>
            </Tabs>
        </div>

        <Modal v-model="createModal" width="500">
            <p slot="header" style="text-align:center">
                <span>{{lanDisplay[languageType][name]['newJobForm']['header']}}</span>
            </p>
            <div style="text-align:center">
                <Form :model="newEmailJob" :label-width="80" style="width: 75%;margin: 0 auto">
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['jobName']">
                        <Input v-model="newEmailJob.jobName" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['jobType']">
                        <Input v-model="newEmailJob.jobType" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['from']">
                        <Input v-model="newEmailJob.from" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['to']">
                        <Input v-model="newEmailJob.to" placeholder="..."></Input>
                    </FormItem>
                    <FormItem :label="lanDisplay[languageType][name]['newJobForm']['config']">
                        <Input v-model="newEmailJob.config" placeholder="..."></Input>
                    </FormItem>
                </Form>
            </div>
            <div slot="footer">
                <Button type="primary" size="large" long :loading="createLoading" @click="createNewEmailJob">Submit</Button>
            </div>
    </Modal>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { uploadExcelFile, getReports, deleteReport } from '../service/apis'

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
            createLoading: false,
            newEmailJob: {
                jobName: '',
                jobType: '',
                from: '',
                to: '',
                config: ''
            }
        }
    },
    methods: {
        createNewEmailJob () {
            this.createLoading = true
            setTimeout(() => {
                this.createLoading = false
                this.createModal = false
            }, 3000)
        },
        async initData (page) {

        }
    },
    created () {
        this.languageType = this.$route.params.lan
        this.lanDisplay = lan
        this.serverUrl = baseUrl

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
    .emailjob-container {
        width: 90%;
        height: 100%;
        margin: 0 auto;
    }
    .left {
        float: left;
    }
</style>
