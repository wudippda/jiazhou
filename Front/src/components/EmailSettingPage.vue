<template>
    <div class="email-container">
        <Breadcrumb class="left">
            <BreadcrumbItem>{{lanDisplay[languageType][name]['title']}}</BreadcrumbItem>
        </Breadcrumb>
        <br>
        <br>
        <Row type="flex" justify="center">
            <Col span="20">
                <Card :bordered="true">
                    <p slot="title">{{lanDisplay[languageType][name]['panelTitle']}}</p>
                    <Row type="flex" justify="center">
                        <Col span="20">
                            <Form :model="emailSetting" :label-width="isSmall ? 50:80" v-if="emailSetting !== {}">
                                <FormItem :label="lanDisplay[languageType][name]['address']">
                                    {{emailSetting.address}}
                                </FormItem>
                                <FormItem :label="lanDisplay[languageType][name]['port']">
                                    {{emailSetting.port}}
                                </FormItem>
                            </Form>
                        </Col>
                    </Row>
                </Card>
            </Col>
        </Row>
        <br>
        <Row type="flex" justify="center">
            <Col span="20">
                <Card :bordered="true">
                    <p slot="title">{{lanDisplay[languageType][name]['changeTitle']}}</p>
                    <Row type="flex" justify="center">
                        <Col span="20">
                            <Form :model="emailSetting" :label-width="isSmall ? 50:80" v-if="emailSetting !== {}">
                                <FormItem :label="lanDisplay[languageType][name]['address']">
                                    <Input size="small" style="width: 70%; float: left" v-model="newAddress"></Input>
                                </FormItem>
                                <FormItem :label="lanDisplay[languageType][name]['port']">
                                    <Input size="small" style="width: 50%; float: left" v-model="newPort"></Input>
                                </FormItem>
                                <Button type="success" @click="isUpdate=true">{{lanDisplay[languageType][name]['sbButton']}}</Button>
                            </Form>
                        </Col>
                    </Row>
                </Card>
            </Col>
        </Row>

        <Modal
            v-if="lanDisplay[languageType][name]['confirmModal'] !== undefined"
            v-model="isUpdate"
            :title="lanDisplay === {} ? '' : lanDisplay[languageType][name]['confirmModal']['title']"
            @on-ok="updateSetting"
            :ok-text="lanDisplay === {} ? '' : lanDisplay[languageType][name]['confirmModal']['okText']"
            :cancel-text="lanDisplay === {} ? '' : lanDisplay[languageType][name]['confirmModal']['cancelText']"
            @on-cancel="cancel">
            <p>{{lanDisplay[languageType][name]['confirmModal']['content']}}</p>
        </Modal>

    </div>
</template>

<script>

import { getEmailSetting, updateEmailSetting } from '../service/apis.js'
import { lan } from '../../config/languageConf.js'

export default {
    data() {
        return {
            name: 'EmailSettingPage',
            lanDisplay: {},
            languageType: 'CN',
            emailSetting: {},
            clientWidth: 0,
            clientHeight: 0,
            isSmall: false,
            isUpdate: false,
            newAddress: '',
            newPort: ''
        }
    },
    methods: {
        updateSetting () {

            let formData = `{"address": "${this.newAddress}"}`
            console.log(formData)

            updateEmailSetting(formData).then(res => {
                console.log(res)
                res = JSON.parse(res)
                if (res['success'] === true) {
                    this.$Notice.success({
                        title: this.lanDisplay[this.languageType][this.name]['confirmModal']['success']['title'],
                        desc: this.lanDisplay[this.languageType][this.name]['confirmModal']['success']['desc']
                    })
                } else {
                    this.$Notice.error({
                        title: this.lanDisplay[this.languageType]['confirmModal']['errors']['failToUpdate']['title'],
                        desc: this.lanDisplay[this.languageType]['confirmModal']['errors']['failToUpdate']['desc']
                    })
                }
            }).catch(err => {
                console.error(err)
                this.$Notice.error({
                    title: 'Fail',
                    desc: 'Fail'
                })
            })
        },
        cancel () {
            this.isUpdate = false
        }
    },
    created () {
        getEmailSetting().then(res => {
            console.log('emailSetting', res)
            this.emailSetting = res
        }).catch(err => {
            console.error(err)
            this.$Notice.error({
                title: this.lanDisplay[languageType]['errors']['failToGet']['title'],
                desc: this.lanDisplay[languageType]['errors']['failToGet']['desc']
            })
        })

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
    .email-container {
        width: 90%;
        height: 100%;
        margin: 0 auto;
    }
    .left {
        float: left
    }
</style>
