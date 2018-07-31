<template>
  <div class="layout">
        <Layout style="height: 100%; width: 100%">
            <Sider ref="side" hide-trigger collapsible :collapsed-width="78" v-model="isCollapsed">
                <Menu :active-name="activeName" theme="dark" width="auto" :class="menuitemClasses" @on-select="dealSelect" style="height: 100%">
                    <MenuItem name="dashboard">
                        <Icon type="clipboard"></Icon>
                        <span>Dashboard</span>
                    </MenuItem>
                    <MenuItem name="tablePage">
                        <Icon type="clipboard"></Icon>
                        <span>Table</span>
                    </MenuItem>
                    <MenuItem name="logout" class="logout-item">
                        <Icon type="log-out"></Icon>
                        <span>Logout</span>
                    </MenuItem>
                </Menu>
            </Sider>
            <Layout>
                <Header :style="{padding: 0}" class="layout-header-bar">
                    <Icon @click.native="collapsedSider" :class="rotateIcon" :style="{margin: '20px 20px 0', float: 'left', cursor: 'pointer'}" type="navicon-round" size="24"></Icon>
                    <h1 class="big-title">Title</h1>
                     <img src="../assets/Logo.jpg" alt="" class="Logo">                    
                </Header>
                <Content :style="{margin: '20px', minHeight: '260px'}">
                    <router-view ref="container"></router-view>
                </Content>
            </Layout>
        </Layout>
    </div>
</template>

<script>
// import { getNotification, checkNotification } from '../service/apis'
export default {
    data () {
        return {
            isCollapsed: false,
            activeName: 'dashboard',
            intervalId: -1,
            unCheckedNotifications: []
        }
    },
    computed: {
        rotateIcon () {
            return [
                'menu-icon',
                this.isCollapsed ? 'rotate-icon' : ''
            ];
        },
        menuitemClasses () {
            return [
                'menu-item',
                this.isCollapsed ? 'collapsed-menu' : ''
            ]
        }
    },
    methods: {
        collapsedSider () {
            this.$refs.side.toggleCollapse();
        },
        dealSelect(name) {
            switch (name) {
                case 'logout':
                    this.logout()
                    break
                case 'dashboard':
                    this.activeName = 'dashboard'
                    this.$router.push({name: 'dashboard', params: {userId: this.$session.get('UserId')}})
                    break
                case 'tablePage':
                    this.activeName = 'tablePage'
                    this.$router.push({name: 'table'})
                    break
                default:
                    break
            }
        },
        logout () {
            this.$session.destroy()
            this.$router.push('/login')
        }
    },
    mounted () {
        console.log(this.$route)
        switch (this.$route.name) {
            case 'dashboard':
                this.activeName = 'dashboard'
                break
            case 'table':
                this.activeName = 'tablePage'
                break
            default:
                break
        }
    },
    beforeCreate () {
        // if (!this.$session.exists()) {
        //     this.$router.push('/login')
        // }
    },
    created () {
        // this.intervalId = setInterval(() => {
        //     getNotification(this.$session.get('UserId')).then(res => {
        //         if (res.statusCode === 'ACCEPTED') {
        //             this.unCheckedNotifications = res.body.res
        //             for (let i = 0; i < this.unCheckedNotifications.length; i++) {
        //                 if (this.unCheckedNotifications[i].mType === 'SUCCESS') {
        //                     this.$Notice.success({
        //                         title: 'Notice',
        //                         desc: this.unCheckedNotifications[i].mContent,
        //                         duration: 0
        //                     })
        //                     this.$refs.container.initData()
        //                 }
        //                 checkNotification(this.unCheckedNotifications[i].mId).then(res => {
        //                     console.log(res)
        //                 }).catch(err => {
        //                     console.error(err)
        //                 })
        //             }
        //             this.unCheckedNotifications = []
        //         }
        //     }).catch(err => {
        //         console.error(err)
        //     })
        // }, 5000)
    },
    beforeDestroy () {
        // clearInterval(this.intervalId)
    }
}
</script>


<style scoped>
    .layout{
        border: 1px solid #d7dde4;
        background: #f5f7f9;
        position: relative;
        border-radius: 4px;
        overflow: hidden;
        height: 100%;
        width: 100%;
    }
    .layout-header-bar{
        background: #fff;
        box-shadow: 0 1px 1px rgba(0,0,0,.1);
    }
    .layout-logo-left{
        width: 90%;
        height: 30px;
        background: #5b6270;
        border-radius: 3px;
        margin: 15px auto;
    }
    .menu-icon{
        transition: all .3s;
    }
    .rotate-icon{
        transform: rotate(-90deg);
    }
    .menu-item span{
        display: inline-block;
        overflow: hidden;
        width: 69px;
        text-overflow: ellipsis;
        white-space: nowrap;
        vertical-align: bottom;
        transition: width .2s ease .2s;
    }
    .menu-item i{
        transform: translateX(0px);
        transition: font-size .2s ease, transform .2s ease;
        vertical-align: middle;
        font-size: 16px;
    }
    .collapsed-menu span{
        width: 0px;
        transition: width .2s ease;
    }
    .collapsed-menu i{
        transform: translateX(5px);
        transition: font-size .2s ease .2s, transform .2s ease .2s;
        vertical-align: middle;
        font-size: 22px;
    }
    .big-title {
        font-weight: 400;
        font-size: 1.2em;
    }
    .logout-item {
        position: absolute;
        bottom: 0;
        width: 100%;
    }
    .Logo {
        position: absolute;
        right: 40px;
        top: 8px;
        height: 49px;
    }
</style>