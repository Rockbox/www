#!/usr/bin/env python

import MySQLdb as db
import cairoplot
import datetime
import random

# Open connection and get a cursor
conn = db.connect(
    host = 'localhost',
    user = 'buildmaster',
    passwd = 'JGQTcTPdPUcGsHb9',
    db = 'rbmaster'
    )
conn.cursorclass = db.cursors.DictCursor
cur = conn.cursor()

# Create Gantt chart
revision = 22244
cur.execute("SELECT revision,client,id,UNIX_TIMESTAMP(time) as end,UNIX_TIMESTAMP(time - INTERVAL timeused SECOND) as start FROM builds WHERE revision = %s ORDER BY client, start", (revision,))

minstart = None
maxend = None
buildround = {}

for row in cur.fetchall():
    if minstart == None:
        print(repr(row))
    if minstart == None or minstart > row['start']:
        minstart = row['start']
    if maxend == None or maxend < row['end']:
        maxend = row['end']

    if row['client'] not in buildround:
        buildround[row['client']] = {}
    buildround[row['client']][row['id']] = [row['start'], row['end']]


print("Revision: %s" % revision)
print("Round started at: %s" % minstart)
print("Round ended at:   %s" % maxend)

pieces   = []
h_legend = []
v_legend = []
colors   = []

# Set markers every n seconds
h_res = 30
for i in range(0, maxend-minstart):
    if i % h_res == 0:
        v_legend.append("%d:%02d" % (i / 60, i % 60))

clients = buildround.keys()
clients.sort(lambda x,y: cmp((x.rsplit('-', 1)[1] + '-' + x.rsplit('-', 1)[0]).lower(), (y.rsplit('-', 1)[1] + '-' + y.rsplit('-', 1)[0]).lower()))
for client in clients:
    print(client)
    thesepieces = []
    for target in buildround[client]:
        build = buildround[client][target]
        build[0] = (float(build[0]) - minstart) / h_res
        build[1] = (float(build[1]) - minstart) / h_res
        print("    %20s %s -> %s" % (target, build[0], build[1]))
        thesepieces.append((build[0], build[1]))
    pieces.append(thesepieces)
    h_legend.append(client)
    random.seed(client.rsplit('-', 1)[1])
    colors.append((random.random(), random.random(), random.random()))

plot = cairoplot.GanttChart('builds_gantt_%d' % revision, pieces, 800, 1000, h_legend, v_legend, colors)
plot.render()
plot.commit()

# All done! Close the connection
conn.close()
