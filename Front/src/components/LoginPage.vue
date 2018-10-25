<template>
  <div class="bg-container">
      <transition name="slide-fade">
        <Card class="login-card" v-if="mode === 'Login'">
            <div>
                <!-- <img src="../assets/logo.svg" class="logo"> -->
                <h1 style="font-size: 1.2em; color: white">数据平台登录</h1>
                <Form ref="loginFormValidation" :model="loginFormValidation" :rules="loginRuleValidation">
                    <FormItem prop="email" class="form-item">
                        <Input type="text" v-model="loginFormValidation.email" placeholder="Email">
                            <Icon type="ios-email-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem>
                    <FormItem prop="password" class="form-item">
                        <Input type="password" v-model="loginFormValidation.password" placeholder="Password" @on-enter="handleSubmit('loginFormValidation')">
                            <Icon type="ios-locked-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem>
                    <FormItem>
                        <Button type="success" size="large" @click="handleSubmit('loginFormValidation')">登录</Button>
                    </FormItem>
                    <FormItem>
                        <a class="register-tip" @click="swithMode('Register')">注册</a>
                    </FormItem>
                </Form>
            </div>
        </Card>
    </transition>
    <transition name="slide-fade">
        <Card class="login-card" v-if="mode === 'Register'">
            <div>
                <!-- <img src="../assets/logo.svg" class="logo"> -->
                <Form ref="registerFormValidation" :model="registerFormValidation" :rules="registerRuleValidation">
                    <FormItem prop="email" class="form-item">
                        <Input type="text" v-model="registerFormValidation.email" placeholder="Email">
                            <Icon type="ios-email-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem>
                    <!-- <FormItem prop="name" class="form-item">
                        <Input type="text" v-model="registerFormValidation.name" placeholder="Name">
                            <Icon type="ios-person-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem> -->
                    <FormItem prop="pwd" class="form-item">
                        <Input type="password" v-model="registerFormValidation.pwd" placeholder="Password">
                            <Icon type="ios-locked-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem>
                    <FormItem prop="pwdcf" class="form-item">
                        <Input type="password" v-model="registerFormValidation.pwdcf" placeholder="Confirm Your Password">
                            <Icon type="ios-locked-outline" slot="prepend"></Icon>
                        </Input>
                    </FormItem>
                    <FormItem>
                        <Button type="info" size="large" @click="handleSubmit('registerFormValidation')">注册</Button>
                    </FormItem>
                    <FormItem>
                        <a class="register-tip" @click="swithMode('Login')">登录</a>
                    </FormItem>
                </Form>
            </div>
        </Card>
    </transition>
  </div>
</template>

<script>
import { login,register, createUser, allocateDocker } from '../service/apis'
var md5 = require('js-md5')
export default {
    data () {
        return {
            name: 'Login',
            mode: 'Login',
            loginFormValidation: {
                email: '',
                password: ''
            },
            loginRuleValidation: {
                email: [
                    { required: true, type: 'email', message: 'Please fill in the correct email', trigger: 'blur' }
                ],
                password: [
                    { required: true, message: 'Please fill in the password.', trigger: 'blur' },
                    { type: 'string', min: 6, message: 'The password length cannot be less than 6 bits', trigger: 'blur' }
                ]
            },
            registerFormValidation: {
                name: '',
                email: '',
                pwd: '',
                pwdcf: ''
            },
            registerRuleValidation: {
                // name: [
                //     { required: true, type: 'string', message: 'Please input your username', trigger: 'blur'}
                // ],
                email: [
                    { required: true, type: 'email', message: 'Please fill in the correct email', trigger: 'blur' }
                ],
                pwd: [
                    { required: true, message: 'Please fill in the password.', trigger: 'blur' },
                    { type: 'string', min: 6, message: 'The password length cannot be less than 6 bits', trigger: 'blur' }
                ],
                pwdcf: [
                    { required: true, message: 'Please fill in the password again.', trigger: 'blur'}
                ]
            },
        }
    },
    methods: {
        /**
         * Submit form
         * @augments formName
         */
        handleSubmit(name) {
            this.$refs[name].validate((valid) => {
                if (valid) {
                    if (this.mode === 'Login') {
                        login(this.loginFormValidation.email, this.loginFormValidation.password).then(res => {
                            // if (res.statusCode === 'ACCEPTED') {
                            //     this.$Message.success('Login success!')
                            //     this.$session.start()
                            //     this.$session.set('Auth', md5(res.body.userId.toString()))
                            //     this.$session.set('UserId', res.body.userId)
                            //     this.$router.push({name: 'dashboard', params: {userId: res.body.userId}})
                            // } else {
                            //     this.$Message.error(res.body.errorMessage)
                            // }
                            console.log(res)
                        }).catch(err => {
                            console.error(err)
                            this.$Message.error('Login fail!')
                        })   
                    } else {
                        if (this.registerFormValidation.pwd !== this.registerFormValidation.pwdcf) {
                            this.registerFormValidation.pwdcf = ''
                            this.$Message.warning('Please input yoour password again')
                        }
                        createUser(this.registerFormValidation.email, this.registerFormValidation.pwd).then(res => {
                            // if (res.statusCode === 'ACCEPTED') {
                            //     this.$Message.success('Register success!')
                            //     this.swithMode('Login')
                            // } else {
                            //     this.$Message.error(res.body.errorMessage)
                            // }
                            console.log(res)
                            let userId = Number.parseInt(this.registerFormValidation.email[0])
                            allocateDocker(userId, this.registerFormValidation.pwd).then(res => {
                                console.log(res)
                                let url = ''
                                url = res['url']
                                window.location.href = 'http://10.60.42.201' + url
                            }).catch(err => {
                                console.error(err)
                            })
                        }).catch(err => {
                            console.error(err)
                            this.$Message.error('Register fail!');
                        })
                    }
                }
            })
        },
        /**
         * Switch between login and register
         * @augments mode
         */
        swithMode(mode) {
            this.mode = 'Change'
            setTimeout(() => this.mode = mode, 1000)
        }
    },
    beforeCreate () {
        if (this.$session.exists()) {
            this.$router.push({name: 'dashboard', params: {userId: this.$session.get('UserId')}})
        } else {
            console.log('session lost')
        }
    },
    mounted () {
        document.title = this.name

        
    },
    created () {
    
    }
}
</script>

<style scoped>
    /* animation */
    .slide-fade-enter-active {
        transition: all .5s ease;
    }
    .slide-fade-leave-active {
        transition: all .5s cubic-bezier(1.0, 0.5, 0.8, 1.0);
    }
    .slide-fade-enter, .slide-fade-leave-active {
        transform: translateX(30px);
        opacity: 0;
    }
    .slide-up-enter-active {
        transition: all .5s ease;
    }
    .slide-up-leave-active {
        transition: all .5s cubic-bezier(1.0, 0.5, 0.8, 1.0);
    }
    .slide-up-enter, .slide-up-leave-active {
        transform: translateY(30px);
        opacity: 0;
    }
    .bg-container {
        background-image: url('/static/img/login-bg.jpg');
        background-size: cover;
        height: 100%;
        width: 100%;
        display: flex;
        display: -webkit-flex;
        flex-direction: column;
        align-items: center
    }
    .login-card {
        position: absolute;
        width: 400px;
        top: 15%; 
        background-color: rgba(255,255,255,0.3);
    }
    .logo {
        width: 150px;
        margin-bottom: 20px;
    }
    .form-item {
        width: 250px; 
        margin: 25px auto;
    }
    .register-tip {
        font-size: 1.13em;
        text-decoration: underline;
    }
</style>