<template>
    <div class="email-container">
<br>
      <Row type="flex" justify="center">
          <Col span="20">
            <Card :bordered="true">
                <p slot="title">Change Password</p>
                <Row type="flex" justify="center">
                    <Col span="20">
                        
                        <Button type="success">Submit</Button>
                    </Col>
                </Row>
            </Card>
          </Col>
      </Row>
    </div>
</template>

<script>
// TODO: Globalize languageType
// TODO: Show Email configuration
// TODO: Edit Email configuration
import { getEmailSetting } from '../service/apis.js'
import { lan } from '../../config/languageConf.js'

export default {
    data() {
        return {
            lanDisplay: {},
            languageType: 'CN'
        }
    },
    methods: {

    },
    created () {
        getEmailSetting().then(res => {
            console.log(res)
        }).catch(err => {
            console.error(err)
        })
    }
}
</script>

<style scoped>
    .email-container {
        width: 100%;
        height: 100%;
    }
</style>
