var lan = {
    EN: {
        Header: {
            title: 'California house renting service backend'
        },
        SiderBar: {
            dashboardPage: 'Dashboard',
            housePage: 'Houses',
            emailSettingPage: 'Email'
        },
        EmailSettingPage: {
            panelTitle: 'Basic Configuration',
            address: 'Address',
            port: 'Port',
            changeTitle: 'Upadte Configuration',
            sbButton: 'Submit',
            errors: {
                failToGet: {
                    title: 'Sorry',
                    desc: 'Fail to get email setting from server'
                }
            }
        }
    },
    CN: {
        Header: {
            title: '加州租房管理系统'
        },
        SiderBar: {
            dashboardPage: '展示面板',
            housePage: '房屋信息',
            emailSettingPage: '邮件配置'
        },
        EmailSettingPage: {
            panelTitle: '配置基本信息',
            address: '地址',
            port: '端口',
            changeTitle: '更新配置',
            sbButton: '提交'
        },
        errors: {
            failToGet: {
                title: '出错了',
                desc: '获取配置失败'
            }
        }
    }
}

export { lan }