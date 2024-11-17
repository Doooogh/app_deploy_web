import request from '@/utils/request'

export function createDeploy(data) {
  return request({
    url: '/deploy/create',
    method: 'post',
    data
  })
}

export function getDeployList(params) {
  return request({
    url: '/deploy/list',
    method: 'get',
    params
  })
}

export function getDeployDetail(id) {
  return request({
    url: `/deploy/${id}`,
    method: 'get'
  })
}

export function getDeployLog(id) {
  return request({
    url: `/deploy/${id}/log`,
    method: 'get'
  })
}

export function getHostLog(deployId, hostId) {
  return request({
    url: `/deploy/${deployId}/host/${hostId}/log`,
    method: 'get'
  })
}

export function cancelDeploy(id) {
  return request({
    url: `/deploy/${id}/cancel`,
    method: 'post'
  })
}

export function rollbackDeploy(id) {
  return request({
    url: `/deploy/${id}/rollback`,
    method: 'post'
  })
}

export function redeployDeploy(id) {
  return request({
    url: `/deploy/${id}/redeploy`,
    method: 'post'
  })
} 