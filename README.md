# Polimi IoT: Challenge 03
## TinyOS broadcast led counter

The file `output/loglistener.txt` contains a (partially) cleaned and filtered output of the events concerning node number 2, for debugging and verification purposes.

### Log file
To view a parsed output one can head over to [Regex101](https://regex101.com/), copy and paste the content of `output/loglistener.txt` in the box and use the following regex:
```
/sender_id\=([1-3]).*counter=([0-9]+).*\n.*\n.*([01]{3})/gm
```
then select `List` from the `FUNCTION` tab on the left side and use the following regex to display a list of lines where the first two values are the `sender_id` and `counter` of every received message respectively, and the value at the right of the arrow is the bit encoding of the resulting led status:
```
$1 $2 --> $3\n
```

The resulting output will be:

```
3 0 --> 000
3 1 --> 100
1 5 --> 101
3 2 --> 001
3 3 --> 101
3 4 --> 001
3 4 --> 101
3 5 --> 001
1 13 --> 000
3 6 --> 100
3 7 --> 000
3 8 --> 100
3 8 --> 000
3 9 --> 100
1 21 --> 101
3 10 --> 000
3 11 --> 100
3 12 --> 000
3 12 --> 100
3 13 --> 000
1 29 --> 001
3 14 --> 101
```

[Regex101](https://regex101.com/) can also be used to build the comma-separated list of values, by using the format regex `$3,` instead, and chopping it down after 20 values. Running the regex will return:

```
000,100,101,001,101,001,101,001,000,100,000,100,000,100,101,000,100,000,100,000
```
