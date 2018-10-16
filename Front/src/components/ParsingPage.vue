<template>
    <div class="parsing-container">
        <div style="height: 80px">
            <Breadcrumb class="left">
                <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
            </Breadcrumb>
            <br>
            <br>
            <Button class="left" type="success" icon="upload" shape="circle" size="large" :loading="isUploading" @click="startUpload">{{lanDisplay[languageType][name]['upload']}}</Button>
            <input type="file" id="excel" style="display: none" accept="application/vnd.ms-excel,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
        </div>
        <br>
        <Row type="flex" justify="center">
            <Col span="24">
                <Card class="for-card"  v-for="(item, index) in reports" :key="index">
                    <p slot="title">
                        <Icon type="gear-b"></Icon>
                        {{item.original_filename}}
                    </p>

                    <Row type="flex" justify="start">
                        <Col span="19" class="card-info">
                            <div>
                                <span>上传时间:</span> &nbsp;{{item.created_at}}
                            </div>
                            <div>
                                <span>状态:</span> &nbsp;<Button :type="item.parsed ? 'success':'error'"></Button>
                            </div>
                        </Col>
                        <Col span="4">
                        </Col>
                    </Row>

                    <a href="#" slot="extra" @click.prevent="changeLimit">
                        <Icon type="ios-loop-strong"></Icon>
                    </a>
                </Card>
            </Col>
        </Row>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { uploadExcelFile, getReports } from '../service/apis'

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
            reports: []
        }
    },
    methods: {
        startUpload () {
            $('#excel').click()
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
        }
    },
    created () {
        this.languageType = this.$route.params.lan
        this.lanDisplay = lan

        getReports(1).then(res => {
            console.log(res)
            this.reports = res.reports
        }).catch(err => {
            console.error(err)
        })
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
    .for-card span {
        font-size: 1.1em;
        color: #1c2438;
        font-weight: 700;
    }
    .card-info div {
        float: left;
        margin-bottom: 5px;
    }
</style>
