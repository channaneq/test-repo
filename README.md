This is a test

- name: List all changed files
        if: steps.filter.outputs.staging == 'true' || steps.filter.outputs.prod == 'true'
        run: |
         staging_applications=(${{ steps.filter.outputs.staging_files }})
         prod_applications=(${{ steps.filter.outputs.prod_files }})
         IFS=','
         filtered_staging_apps=()
         filtered_staging_clusters=()
         filtered_prod_apps=()
         filtered_prod_clusters=()
         
         # Get the staging application names first
         for staging_file in ${staging_applications[@]}; do
            staging_base="$(dirname $staging_file)"
            staging_application="$(basename $staging_base)"
            filtered_staging_apps+=("$staging_application") 
         # Get the staging cluster names 
         if [[ $staging_file == *base-config* ]]; # If the base config directory is changed we need to go through this
         then
            staging_filter_1=$(dirname $staging_base)
            staging_cluster_name=$(basename $staging_filter_1)
            filtered_staging_clusters+=("$staging_cluster_name")
         else
            staging_filter_1=$(dirname $staging_base)
            staging_filter_2=$(dirname $staging_filter_1)
            staging_cluster_name=$(basename $staging_filter_2)
            filtered_staging_clusters+=("$staging_cluster_name")
         fi
         done
         echo "applications_staging=${filtered_staging_apps[@]}" >> $GITHUB_ENV
         echo "clusters_staging=${filtered_staging_clusters[@]}" >> $GITHUB_ENV
         
         for prod_file in ${prod_applications[@]}; do # Get prod application 
            prod_base="$(dirname $prod_file)"
            prod_application="$(basename $prod_base)"
            filtered_prod_apps+=("$prod_application")  
         # Get prod cluster names
         if [[ $prod_file == *base-config* ]]; # If the base config directory is changed we need to go through this
         then
            prod_filter_1=$(dirname $prod_base)
            prod_cluster_name=$(basename $prod_filter_1)
            filtered_prod_clusters+=("$prod_cluster_name")
         else
            prod_filter_1=$(dirname $prod_base)
            prod_filter_2=$(dirname $prod_filter_1)
            prod_cluster_name=$(basename $prod_filter_2)
            filtered_prod_clusters+=("$prod_cluster_name")
         fi
         done
         
         echo "applications_prod=${filtered_prod_apps[@]}" >> $GITHUB_ENV
         echo "clusters_prod=${filtered_prod_clusters[@]}" >> $GITHUB_ENV
