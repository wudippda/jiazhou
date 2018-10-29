var lan = {
    EN: {
        Header: {
            title: 'House Renting'
        },
        SiderBar: {
            dashboardPage: 'Dashboard',
            parsingPage: 'Parsing',
            housePage: 'Houses',
            emailSettingPage: 'Email',
            emailJobPage: 'Email Job',
            logOut: 'Logout'
        },
        EmailSettingPage: {
            title: 'Email Setting',
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
        },
        ParsingPage: {
            title: 'Parsing Center',
            upload: 'Upload Excel File',
            uploadTime: 'Upload time',
            state: 'State',
            stateSuccess: 'Parsed',
            stateNotYet: 'Not Yet',
            download: 'Download',
            downloadLink: 'Link',
            desc: 'Desc',
            descContent: 'See more details in Housing page',
            success: {
                successToUpload: {
                    title: 'Success',
                    desc: 'Success to upload your file!'
                },
                successToDelete: {
                    title: 'Success',
                    desc: 'Success to delete this report!'
                }
            },
            errors: {
                failToUpload: {
                    title: 'Sorry',
                    desc: 'Fail to upload your excel file, error msg: '
                },
                failToDelete: {
                    title: 'Sorry',
                    desc: 'Fail to delete this report!'
                }
            }
        },
        HousingPage: {
            title: 'Housing Center'
        }
    },
    CN: {
        Header: {
            title: '加州租房'
        },
        SiderBar: {
            dashboardPage: '展示面板',
            parsingPage: '解析中心',
            housePage: '房屋信息',
            emailSettingPage: '邮件配置',
            emailJobPage: '邮件任务',
            logOut: '登出'
        },
        EmailSettingPage: {
            title: '邮件配置',
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
                    },
                    failToDelete: {
                        title: '出错了',
                        desc: '删除报告失败了!'
                    }
                }
            },
            errors: {
                failToGet: {
                    title: '出错了',
                    desc: '获取配置失败'
                }
            }
        },
        ParsingPage: {
            title: '解析中心',
            upload: '上传Excel文件',
            uploadTime: '上传时间',
            state: '状态',
            stateSuccess: '解析完毕',
            stateNotYet: '还未解析',
            download: '下载',
            downloadLink: '下载链接',
            desc: '说明',
            descContent: '更多详情见Housing界面',
            success: {
                successToUpload: {
                    title: '成功',
                    desc: '成功上传!'
                },
                successToDelete: {
                    title: '成功',
                    desc: '成功删除报告!'
                }
            },
            errors: {
                failToUpload: {
                    title: '出错了',
                    desc: '上传出错，错误信息: '
                }
            }
        },
        HousingPage: {
            title: '房产中心'
        }
    }
}

export { lan }