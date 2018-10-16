<template>
    <div class="parsing-container">
        <Breadcrumb class="left">
            <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
        </Breadcrumb>
        <br>
        <br>
        <Button class="left" type="success" icon="upload" shape="circle" size="large" :loading="isUploading" @click="startUpload">{{lanDisplay[languageType][name]['upload']}}</Button>
        <input type="file" id="excel" style="display: none" accept="application/vnd.ms-excel,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
        <Row type="flex" justify="center">
            <Col span="20">
                <!-- <Card style="width:350px">
        <p slot="title">
            <Icon type="ios-film-outline"></Icon>
            Classic film
        </p>
        <a href="#" slot="extra" @click.prevent="changeLimit">
            <Icon type="ios-loop-strong"></Icon>
            Change
        </a>
        <ul>
            
        </ul>
    </Card> -->
            </Col>
        </Row>
    </div>
</template>

<script>

import { lan } from '../../config/languageConf.js'
import { uploadExcelFile } from '../service/apis'

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
            isUploading: false
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
        width: 100%;
        height: 100%;
    }
    .left {
        float: left
    }
</style>
