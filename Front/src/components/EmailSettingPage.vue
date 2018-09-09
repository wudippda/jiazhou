<template>
    <div class="email-container">
    <br>
      <Row type="flex" justify="center">
          <Col span="20">
            <Card :bordered="true">
                <p slot="title">{{lanDisplay[languageType][name]['panelTitle']}}</p>
                <Row type="flex" justify="center">
                    <Col span="20">
                        <Form :model="emailSetting" label-width="80" v-if="emailSetting !== {}">
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
                        <Form :model="emailSetting" label-width="80" v-if="emailSetting !== {}">
                            <FormItem :label="lanDisplay[languageType][name]['address']">
                                <Input size="small" style="width: 20%; float: left"></Input>
                            </FormItem>
                            <FormItem :label="lanDisplay[languageType][name]['port']">
                                <Input size="small" style="width: 10%; float: left"></Input>
                            </FormItem>
                            <Button type="success">{{lanDisplay[languageType][name]['sbButton']}}</Button>
                        </Form>
                    </Col>
                </Row>
            </Card>
          </Col>
      </Row>
    </div>
</template>

<script>
// TODO: Edit Email configuration
import { getEmailSetting } from '../service/apis.js'
import { lan } from '../../config/languageConf.js'

export default {
    data() {
        return {
            name: 'EmailSettingPage',
            lanDisplay: {},
            languageType: 'CN',
            emailSetting: {}
        }
    },
    methods: {

    },
    created () {
        getEmailSetting().then(res => {
            console.log('emailSetting', res)
            this.emailSetting = JSON.parse(res)
        }).catch(err => {
            console.error(err)
            this.$Notice.error({
                title: this.lanDisplay[languageType]['errors']['failToGet']['title'],
                desc: this.lanDisplay[languageType]['errors']['failToGet']['desc']
            })
        })

        this.lanDisplay = lan
        this.languageType = this.$route.params.lan
    },
    watch: {
        '$route' (to, from) {
            this.languageType = to.params.lan
        }
    }
}
</script>

<style scoped>
    .email-container {
        width: 100%;
        height: 100%;
    }
</style>
