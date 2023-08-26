| Author     | Version | Status   | Modified    |
| ---------- | ------- | -------- | ----------- |
| J.Stolberg | 0.1     | Proposal | 27 Jun 2023 |



# BEP 006: Signs Bot Commands

### Send Command / Trigger Action

| Command     | Topic (num) | Payload (array/string) | Remarks                                                      |
| ----------- | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off | 1           | [num]                  | Turn bot on/off<br />*num* is the state: 0 = "off", 1 = "on" |
|             |             |                        |                                                              |
|             |             |                        |                                                              |


### Request Data

| Command   | Topic (num) | Payload (array/string) | Response (array/string) | Remarks to the response                                      |
| --------- | ----------- | ---------------------- | ----------------------- | ------------------------------------------------------------ |
| Bot State | 128         | -                      | [num]                   | RUNNING = 1, BLOCKED = 2,<br /> STANDBY = 3, NOPOWER = 4,<br />FAULT = 5, STOPPED = 6,<br />CHARCHING = 7 |
|           |             |                        |                         |                                                              |
|           |             |                        |                         |                                                              |
