<template>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="page-header-image">
                    <h1 class="title">Donate Crypto to People In Need</h1>
                </div>
            </div>
            <div class="col-md-12">
                <nav class="navbar navbar-expand-lg navbar-light bg-light">
                    <ul class="navbar-nav">
                        <router-link tag="li" class="nav-link" to="/" exact>
                            <a>All Projects</a>
                        </router-link>
    
                        <router-link tag="li" class="nav-link" to="/projects?mine=true">                        
                            <a>My Projects</a>
                        </router-link>

                        <li class="nav-link">
                            <label>Account: </label>
                            <strong><a @click="handleClick">{{account}}</a></strong>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
    import {ref, inject} from 'vue';
    import {useRouter} from 'vue-router';
    import {detectWallet, connect, getAccount, addListener} from "../api/contract";

    export default {
        setup() {
            if (!detectWallet()) {
                alert("no wallet installed!");
            }
            // connect to account
            const account = ref('connect');
            async function handleClick() {
                await connect();
                account.value = await getAccount();
            }

            handleClick();
            addListener(handleClick);

            const onRefresh = inject<Function>('reload')

            // const router = useRouter();
            // const navToHome = () => {
            //     router.push({path: '/projects'});

            //     onRefresh && onRefresh()
            // };
            // const navToMyProjects = () => {
            //     router.push({path: '/projects', query: {mine: 'true'}});
            //     console.log("onrefresh", onRefresh)
            //     onRefresh && onRefresh()
            // };

            return {handleClick, account}
        },
    }
</script>

<style>
</style>
