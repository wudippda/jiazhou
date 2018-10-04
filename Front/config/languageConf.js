var lan = {
    EN: {
        Header: {
            title: 'House Renting'
        },
        SiderBar: {
            dashboardPage: 'Dashboard',
            housePage: 'Houses',
            emailSettingPage: 'Email',
            logOut: 'logout'
        },
        EmailSettingPage: {
            panelTitle: 'Basic Configuration',
            address: 'Address',
            port: 'Port',
            changeTitle: 'Upadte Configuration',
            sbButton: 'Submit',
            confirmModal: {
                title: 'WARNING',
                content: 'Are u true to update the setting?',
                okText: 'OK',
                cancelText: 'CANCEL',
                success: {
                    title: 'Success',
                    desc: 'Success to update email setting'
                },
                errors: {
                    failToUpdate: {
                        title: 'Sorry',
                        desc: 'Fail to update email setting'
                    }
                }
            },
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
            title: '加州租房'
        },
        SiderBar: {
            dashboardPage: '展示面板',
            housePage: '房屋信息',
            emailSettingPage: '邮件配置',
            logOut: '登出'
        },
        EmailSettingPage: {
            panelTitle: '配置基本信息',
            address: '地址',
            port: '端口',
            changeTitle: '更新配置',
            sbButton: '提交',
            confirmModal: {
                title: '警告',
                content: '确认提交修改？',
                okText: '确定',
                cancelText: '取消',
                success: {
                    title: '成功',
                    desc: '成功更新邮件IP'
                },
                errors: {
                    failToUpdate: {
                        title: '出错了',
                        desc: '更新邮件IP失败'
                    }
                }
            },
            errors: {
                failToGet: {
                    title: '出错了',
                    desc: '获取配置失败'
                }
            }
        }
    }
}

export { lan }