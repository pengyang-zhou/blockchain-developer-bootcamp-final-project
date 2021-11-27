<template>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="page-header-image">
                    <h1 class="title">Donate Crypto to Peopel In Need</h1>
                </div>
            </div>
            <div class="col-md-12">
                <nav class="navbar navbar-expand-lg navbar-light bg-light">
                    <ul class="navbar-nav">
                        <router-link tag="li" class="nav-link" to="/" exact>
                            <a>All Projects</a>
                        </router-link>
    
                        <router-link tag="li" class="nav-link" to="/my" exact>
                            <a>My Projects</a>
                        </router-link>
    
                        <router-link tag="li" class="nav-link" to="/new" exact>
                            <a>New Project</a>
                        </router-link>
    
                        <router-link tag="li" class="nav-link" to="/project/1" exact>
                            <a>Project Detail</a>
                        </router-link>
    
                        <li class="nav-link"></li>
                        <li class="nav-link">
                            <label>Account: </label>
                            <strong><a @click="handleClick">{{account}}</a></strong>
                            <!-- <strong :class="connectedClass">
                                {{ bcConnected ? 'Connected' : 'Not Connected' }}
                            </strong> -->
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    </div>
</template>

<script>
    import {ref} from 'vue';
    import {authenticate, getAccount, addListener} from "../api/contract"
    export default {
        setup() {
            // connect to account
            const account = ref('connect');
            async function handleClick() {
                await authenticate();
                account.value = await getAccount();
            }

            handleClick();
            addListener(handleClick)

            return {handleClick, account}
        }
    }
</script>

<style>
</style>
