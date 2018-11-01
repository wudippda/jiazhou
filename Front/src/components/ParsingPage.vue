<template>
    <div class="parsing-container">
        <div style="height: 80px">
            <Breadcrumb class="left">
                <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
            </Breadcrumb>
            <br>
            <br>
            <Button class="left" type="success" icon="upload" shape="circle" size="large" :loading="isUploading" @click="startUpload">{{lanDisplay[languageType][name]['upload']}} <span id="progress"></span> </Button>
            <input type="file" id="excel" style="display: none" accept="application/vnd.ms-excel,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,aplication/zip,application/rar">
        </div>
        <br>
        <Row type="flex" justify="center">
            <Col span="24">
                <Card class="for-card"  v-for="(item, index) in reports" :key="index">
                    <p slot="title" style="text-align:center">
                        <Icon type="gear-b"></Icon>
                        {{item.original_filename}}
                    </p>

                    <Row type="flex" justify="start" class="card-info">
                        <Col span="19">
                            <p>{{lanDisplay[languageType][name]['uploadTime']}}:<span>&nbsp;{{item.created_at}}</span></p>
                            <br>
                            <p>{{lanDisplay[languageType][name]['state']}}: 
                                <Button shape="circle" size="small" type="error" v-if="!item.parsed">{{lanDisplay[languageType][name]['stateNotYet']}}</Button>
                                <Button shape="circle" size="small" type="success" v-if="item.parsed">{{lanDisplay[languageType][name]['stateSuccess']}}</Button>
                            </p>
                            <br>
                            <p>{{lanDisplay[languageType][name]['download']}}: <a style="font-size: 0.9em" :href="serverUrl + item.report.url">{{lanDisplay[languageType][name]['downloadLink']}}</a></p>
                            <br>
                            <p>{{lanDisplay[languageType][name]['desc']}}: <span style="font-size: 0.9em">{{lanDisplay[languageType][name]['descContent']}}</span></p>
                        </Col>
                    </Row>

                    <a href="#" slot="extra" @click.prevent="deleteParse(item)">
                        <Icon type="ios-close-outline"></Icon>
                    </a>
                </Card>
            </Col>
        </Row>
        <Page :total="totalPage * 5" size="small" :current="currentPage" page-size="5" @on-change="changePage"></Page>
        <br><br>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { uploadExcelFile, getReports, deleteReport } from '../service/apis'
import { baseUrl } from '../../config/index'

import $ from 'jquery'

export default {
    data() {
        return {
            name: 'ParsingPage',
            lanDisplay: {},
            languageType: 'CN',
            clientWidth: 0,
            clientHeight: 0,
            isSmall: false,
            testFile: null,
            isUploading: false,
            reports: [],
            serverUrl: '',
            currentPage: 1,
            totalPage: 1
        }
    },
    methods: {
        changePage (page) {
            this.currentPage = page
            this.initData(page)
        },
        deleteParse (item) {
            deleteReport(item.id).then(res => {
                console.log(res)
                if (res['deleteSuccess'] === true) {
                    console.log('test')
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['success']['successToDelete']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['success']['successToDelete']['desc']
                    }) 
                    this.initData(1)  
                }
            }).catch(err => {
                console.error(err)
                this.$Notice.error({
                    title: this.lanDisplay[this.languageType][this.name]['success']['failToDelete']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['success']['failToDelete']['desc']
                })
            })
        },
        startUpload () {
            $('#excel').click()
            $('#progress').html('')
            $('#excel').change(() => {
                console.log('fuck')
                this.uploadExcel()
            })
        },
        uploadExcel () {
            this.testFile = $('#excel')[0].files[0]
            console.log(this.testFile)
            this.isUploading = true
            uploadExcelFile(this.testFile).then(res => {
                console.log(res)
                if (res['uploadSuccess'] !== undefined && res['uploadSuccess'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['success']['successToUpload']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['success']['successToUpload']['desc']
                    })
                    this.initData(1)
                } else {
                    this.$Notice.error({
                        title: this.lanDisplay[this.languageType][this.name]['errors']['failToUpload']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['errors']['failToUpload']['desc'] + res['errorMsg']
                    })
                }
                this.isUploading = false
            }).catch(err => {
                console.error(err)
                this.$Notice.error({
                    title: this.lanDisplay[this.languageType][this.name]['errors']['failToUpload']['title'],
                    desc: this.lanDisplay[this.languageType][this.name]['errors']['failToUpload']['desc']
                })
                this.isUploading = false
            })
        },
        async initData (page) {
            getReports(page).then(res => {
                console.log('reports', res)
                this.reports = res.reports
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
    .parsing-container {
        width: 90%;
        height: 100%;
        margin: 0 auto;
    }
    .left {
        float: left
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
