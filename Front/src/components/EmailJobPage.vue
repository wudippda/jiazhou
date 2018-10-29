<template>
    <div class="emailjob-container">
        <div style="height: 80px">
            <Breadcrumb class="left">
                <BreadcrumbItem>Email Job Management</BreadcrumbItem>
            </Breadcrumb>
            <br>
            <br>
            <Button class="left" type="success" icon="upload" shape="circle" size="large" :loading="isUploading" @click="startUpload">New Job <span id="progress"></span> </Button>
        </div>
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
            totalPage: 1
        }
    },
    methods: {
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
