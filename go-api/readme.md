# Go API Templates

Generates a CRUD API using gorm and gin

## Sample Commands

Generate using mysql
```
monstarillo mysql --t /mnt/c/code/patricks-monstarillo-templates/go-api/templates-mysql.json \
    --u admin \
    --p <YourPassword> \
    --db "tcp(localhost:3306)/employees" \
    --schema "employees"
```

Generate using postgres
```
monstarillo postgres --t /mnt/c/code/patricks-monstarillo-templates/go-api/templates-postgres.json \
    --u postgres \
    --p <YourPassword> \
    --db "chinhook-db" \
    --host "localhost" \
    --schema "public"
```    