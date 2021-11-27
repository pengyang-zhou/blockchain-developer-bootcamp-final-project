import Web3 from 'web3'
import EthDonation from './EthDonation.json'

const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(EthDonation.abi, '0xd84F2C8A81931abe8877D01D56dC2753cd738939');

function addListener(fn: Function) {
    //@ts-ignore
    ethereum.on('accountsChanged', fn)
}

async function authenticate() {
    //@ts-ignore
    await window.ethereum.enable();
}

async function getAccount() {
    return (await web3.eth.getAccounts())[0];
}

export declare interface Project {
    index: number,
    founder: string,
    title: string,
    description: string,
    endTime: number,
    amountFunded: number,
    amountLeft: number,
    expenseCount: number
}

export declare interface Expense {
    index: number,
    description: string,
    allocation: number,
    approvedAmount: number,
    state: number
}

async function getProjects() : Promise<Project[]> {
    const projectCount = await contract.methods.projectCount().call();
    const projects = [];
    for (let i=1; i<projectCount; i++) {
        projects.push(await getProject(i));
    }
    return projects;
}

async function getProject(index:number) : Promise<Project> {
    const data = await contract.methods.projects(index).call();
    data.amountFunded = Web3.utils.fromWei(data.amountFunded, 'ether')
    data.amountLeft = Web3.utils.fromWei(data.amountLeft, 'ether')
    return {index, ...data}
}

export {
    getAccount,
    authenticate,
    contract,
    addListener,
    getProjects,
    getProject
}

