-- Populating Property Address Data --

SELECT *
FROM nashville_housing.`nashville housing data for data cleaning`
-- where PropertyAddress is null
order by ParcelID;

SELECT par.ParcelID, par.PropertyAddress, cel.ParcelID, cel.PropertyAddress,
coalesce(par.PropertyAddress, cel.PropertyAddress)
FROM nashville_housing.`nashville housing data for data cleaning` par
join nashville_housing.`nashville housing data for data cleaning` cel
	on par.ParcelID = cel.ParcelID
    and par.UniqueID <> cel.UniqueID
    where par.PropertyAddress is null;
    
update nashville_housing.`nashville housing data for data cleaning` par
join nashville_housing.`nashville housing data for data cleaning` cel
	on par.ParcelID = cel.ParcelID
    and par.UniqueID <> cel.UniqueID
    set par.PropertyAddress = coalesce(par.PropertyAddress, cel.PropertyAddress)
    where par.PropertyAddress is null;
    
    
SELECT PropertyAddress
FROM nashville_housing.`nashville housing data for data cleaning`;
-- where PropertyAddress is null
-- order by ParcelID;

select 
substring(PropertyAddress, 1, locate(',', PropertyAddress)- 1) as Address,
substring(PropertyAddress, locate(',', PropertyAddress) +1) , 
length(PropertyAddress) as Address
FROM nashville_housing.`nashville housing data for data cleaning`;
 
 
 -- Breaking Down Property Addresses Into Individual Columns (Address, City, State) --
Alter table nashville_housing.`nashville housing data for data cleaning`
Add PropertySplitAddress nvarchar(255);

Update nashville_housing.`nashville housing data for data cleaning`
set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress)- 1);

Alter table nashville_housing.`nashville housing data for data cleaning`
add PropertySplitCity nvarchar(255);

Update nashville_housing.`nashville housing data for data cleaning`
set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) +1);

select *
FROM nashville_housing.`nashville housing data for data cleaning`;

-- Breaking Down Owner Addresses Into Individual Columns (Address, City, State) --
select OwnerAddress
FROM nashville_housing.`nashville housing data for data cleaning`;

select
    Substring_index(OwnerAddress, ',', 1) as Address,  
    trim(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) as City,  
    trim(SUBSTRING_INDEX(OwnerAddress, ',', -1)) as State  
FROM 
    nashville_housing.`nashville housing data for data cleaning`;
    
    --
Alter table nashville_housing.`nashville housing data for data cleaning`
Add OwnerSplitAddress nvarchar(255);

Update nashville_housing.`nashville housing data for data cleaning`
set OwnerSplitAddress =  substring_index(OwnerAddress, ',', 1);

Alter table nashville_housing.`nashville housing data for data cleaning`
add OwnerSplitCity nvarchar(255);

Update nashville_housing.`nashville housing data for data cleaning`
set OwnerSplitCity = trim(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)); 

Alter table nashville_housing.`nashville housing data for data cleaning`
add OwnerSplitState nvarchar(255);

Update nashville_housing.`nashville housing data for data cleaning`
set OwnerSplitState = trim(SUBSTRING_INDEX(OwnerAddress, ',', -1));

select *
FROM nashville_housing.`nashville housing data for data cleaning`;

-- sold as vacant --
select distinct(SoldAsVacant), count(SoldAsVacant)
FROM nashville_housing.`nashville housing data for data cleaning`
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
FROM nashville_housing.`nashville housing data for data cleaning`;


update nashville_housing.`nashville housing data for data cleaning`
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end;

-- removing duplicates --
with row_num_cte AS (
    select *,
           row_number() over (
           partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           order by UniqueID) AS row_num
    from nashville_housing.`nashville housing data for data cleaning`
)
select *
from nashville_housing.`nashville housing data for data cleaning` t
join row_num_cte r
on t.UniqueID = r.UniqueID
where r.row_num > 1;

-- delete unused columns --
select *
from nashville_housing.`nashville housing data for data cleaning`;

alter table nashville_housing.`nashville housing data for data cleaning`
drop column OwnerAddress,
drop column TaxDistrict, 
drop column PropertyAddress;
