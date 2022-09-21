
select * from myportfolio..housing
----------------------------------
--standardize date frormat

select saledatecoverted, convert(date,saledate)
from myportfolio.dbo.housing
alter table housing
add saledatecoverted date;
update housing set saledatecoverted = convert(date,saledate)


-- populate property adress data

select a.parcelid, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from myportfolio.dbo.housing a
join myportfolio.dbo.housing b
on a.parcelid = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]



update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from myportfolio.dbo.housing a
join myportfolio.dbo.housing b
on a.parcelid = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]


--breaking out adress into indivisual colums > adress, city, state


select Propertyaddress
from myportfolio..housing


select
substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as adress,
substring (Propertyaddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as city
from myportfolio..housing



alter table myportfolio..housing
add propertysplitadress nvarchar(255);
alter table myportfolio..housing
add propertysplitcity nvarchar(255);


update myportfolio..housing
set propertysplitadress = substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)
update myportfolio..housing
set propertysplitcity = substring (Propertyaddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))


select owneraddress
from myportfolio..housing

-- owners address split

select
parsename(replace(owneraddress,',','.'),1),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),3)
from myportfolio..housing


alter table myportfolio..housing
add ownersplitaddress nvarchar(255);

update myportfolio..housing
set ownersplitaddress = parsename(replace(owneraddress,',','.'),3)

alter table myportfolio..housing
add ownersplitcity nvarchar(255);

update myportfolio..housing
set ownersplitcity = parsename(replace(owneraddress,',','.'),2)

alter table myportfolio..housing
add ownersplitstate nvarchar(255);

update myportfolio..housing
set ownersplitstate = parsename(replace(owneraddress,',','.'),1)


select * from myportfolio..housing


-- change Y , N >>> yes and no

Select distinct(SoldAsVacant),count(soldasvacant) 
from myportfolio..housing
group by soldasvacant
order by 2

Select distinct(SoldAsVacant),
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from myportfolio..housing


update myportfolio..housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from myportfolio..housing


--remove Duplicate, use CTE

with RownumCTE as (
select * ,
row_number() over (
partition by parcelID,
		     propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by uniqueID
			 ) as row_num
from myportfolio..housing
)
--  DELETE
select *
from RownumCTE
where row_num > 1




-- Delete unused columns

alter table myportfolio..housing
drop column owneraddress, taxdistrict, propertyaddress, saledate

select * from myportfolio..housing