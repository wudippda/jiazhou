<template>
    <div class="dashboard-container">
        <h1 style="font-size: 4em">In developing</h1>
        <br>
        <Table border :columns="columns" :data="dataSource"></Table>
        <br>
        <Page :total="pageTotal" size="small" @on-change="changePage"></Page>
    </div>
</template>

<script>
export default {
    data () {
        return {
            columns: [
                {
                    title: 'Name',
                    key: 'name',
                    render: (h, params) => {
                        return h('div', [
                            h('Icon', {
                                props: {
                                    type: 'person'
                                }
                            }),
                            h('strong', params.row.name)
                        ]);
                    }
                },
                {
                    title: 'Age',
                    key: 'age'
                },
                {
                    title: 'Address',
                    key: 'address'
                },
                {
                    title: 'Action',
                    key: 'action',
                    width: 150,
                    align: 'center',
                    render: (h, params) => {
                        return h('div', [
                            h('Button', {
                                props: {
                                    type: 'primary',
                                    size: 'small'
                                },
                                style: {
                                    marginRight: '5px'
                                },
                                on: {
                                    click: () => {
                                        // TODO
                                    }
                                }
                            }, 'View'),
                            h('Button', {
                                props: {
                                    type: 'error',
                                    size: 'small'
                                    },
                                    on: {
                                        click: () => {
                                            // TODO
                                        }
                                    }
                                }, 'Delete')
                            ]);
                        }
                    }
            ],
            dataSource: [
                {
                    name: 'John Brown',
                    age: 18,
                    address: 'New York No. 1 Lake Park'
                },
                {
                    name: 'Jim Green',
                    age: 24,
                    address: 'London No. 1 Lake Park'
                },
                {
                    name: 'Joe Black',
                    age: 30,
                    address: 'Sydney No. 1 Lake Park'
                },
                {
                    name: 'Jon Snow',
                    age: 26,
                    address: 'Ottawa No. 2 Lake Park'
                }
            ],
            pageTotal: 0
        }
    },
    methods: {
        changePage (page) {

        }
    }
}
</script>

<style scoped>
    .dashboard-container {
        margin: 0 auto;
        width: 90%;
        height: 100%;
    }
</style>
