<template>
  <div class="dashboard-container">
      <Row :gutter="30" type="flex" justify="center">
          <Col span="10">
            <Card :bordered="true" style="height: 200px">
                <p slot="title">Basic Information</p>
                <br>
                <Row type="flex">
                    <Col span="10">
                        <Icon type="ios-person"></Icon>
                        <strong class="card-label">Name</strong>
                    </Col>
                    <Col>
                        <p>{{user.mName}}</p>
                    </Col>
                </Row>
                <br><br>
                <Row type="flex">
                    <Col span="10">
                        <Icon type="ios-email"></Icon>
                        <strong class="card-label">Email</strong>
                    </Col>
                    <Col>
                        <p>{{user.mEmail}}</p>
                    </Col>
                </Row>
                <br><br>
                <Row type="flex">
                    <Col span="10">
                        <Icon type="android-cloud"></Icon>
                        <strong class="card-label">Model</strong>
                    </Col>
                    <Col>
                        <p>{{user.mNLPModels.length}}</p>
                    </Col>
                </Row>
            </Card>
          </Col>
          <Col span="10">
            <Card :bordered="true" style="height: 200px">
                <p slot="title">Limits of Authority</p>
                <Row type="flex" justify="center">
                    <Col span="15">
                        <ul class="authority-list">
                            <li>Create NLP model</li>
                            <li>Up to 10 NLP models</li>
                            <li>Use all servers to train model</li>
                        </ul>
                    </Col>
                </Row>
            </Card>
          </Col>
      </Row>
      <br>
      <Row type="flex" justify="center">
          <Col span="20">
            <Card :bordered="true">
                <p slot="title">Change Password</p>
                <Row type="flex" justify="center">
                    <Col span="20">
                        <Form :model="form" :label-width="140">
                            <FormItem label="Old Password">
                                <Input type="password" v-model="form.oldpwd" placeholder="Old Password" style="width: 40%">
                                    <Icon type="ios-locked-outline" slot="prepend"></Icon>
                                </Input>
                            </FormItem>
                            <FormItem label="New Password">
                                <Input type="password" v-model="form.pwd" placeholder="New Password" style="width: 40%">
                                    <Icon type="ios-locked-outline" slot="prepend"></Icon>
                                </Input>
                            </FormItem>
                            <FormItem label="New Password Again">
                                <Input type="password" v-model="form.pwdcf" placeholder="New Password Again" style="width: 40%">
                                    <Icon type="ios-locked-outline" slot="prepend"></Icon>
                                </Input>
                            </FormItem>
                        </Form>
                        <Button type="success">Submit</Button>
                    </Col>
                </Row>
            </Card>
          </Col>
      </Row>

  </div>
</template>

<script>
// import { getUserDetails } from '../service/apis'
export default {
    data () {
        return {
            name: 'Dashboard',
            user: {
                mName: '',
                mEmail: '',
                mNLPModels: []
            },
            form: {
                oldpwd: '',
                pwd: '',
                pwdcf: ''
            }
        }
    },
    methods: {
        async initData () {
            // getUserDetails(this.$route.params.userId).then(res => {
            //     console.info('user', res)
            //     if (res.body.info === 'Success') {
            //         this.user = res.body.user
            //     } else {
            //         this.$Notice.error({
            //             title: 'Error to load this user',
            //             desc: ''
            //         });
            //     }
            // }).catch(err => {
            //     console.error(err)
            //     this.$Notice.error({
            //         title: 'Error to load this user',
            //         desc: err.toString()
            //     });
            // })
        }
    },
    beforeCreate () {
        // if (!this.$session.exists()) {
        //     this.$router.push('/login')
        // }
    },
    created () {
        this.initData()
    },
    mounted () {
        document.title = this.name
    }
}
</script>

<style scoped>
    .dashboard-container {
        width: 100%;
        height: 100%;
    }
    .card-label {
        font-weight: 400;
        font-size: 1.2em;
    }
    .authority-list {
        margin: 5px auto;
    }
    .authority-list li {
        text-align: start;
        margin: 12px;
        list-style: square;
    }
</style>