import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  duration: '1m',
  vus: 15,
  thresholds: {
    http_req_duration: ['p(95)<500'],
    checks: ['rate>0.95']
  },
  noConnectionReuse: true
};

export default function () {
  const params = {
    timeout: 2000
  }
  const url = `http://${__ENV.HOST}`
  const res = http.get(url, params);
  check(res, {
    'status is 200': (res) => res.status === 200,
  });
  sleep(1);
}
